extends Node2D
## UNICORN KITTENS — PC port (Godot 4)
##
## A faithful re-implementation of the CityXen Commodore 64 game in ../c64.
## Fly Clicky the unicorn around the left of the screen, catch falling goodies
## (carry up to 5), deliver them to the Treats For Good People Center to score,
## rescue kittens, and dodge the bad stuff. *GIMMICK*: FIRE = RAINBOW BARF, spends
## one goodie to vaporise every bad thing on screen.
##
## The gameplay constants and logic mirror the C64 source (config.asm, game_loop.asm,
## items.asm, unicorn.asm, barf.asm, util.asm). Positions are kept in the C64 sprite
## coordinate space so the original tuning numbers transfer directly; they are mapped
## to the 320x200 logical screen via screen_pos(). The right columns (x >= 240) are a
## character-style HUD, exactly as on the C64.

# ---------------------------------------------------------------------------------------
# Constants (from config.asm)
# ---------------------------------------------------------------------------------------
const UNI_SPEED := 2
const UNI_X_MIN := 24
const UNI_X_MAX := 224
const UNI_Y_MIN := 52
const UNI_Y_MAX := 216

const NUM_ITEMS := 6
const ITEM_TOP := 50
const ITEM_BOTTOM := 234

const IT_CAKE := 0
const IT_CANDY := 1
const IT_KITTEN := 2
const IT_TOOL := 3
const IT_POO := 4
const IT_EMAIL := 5

const CAT_GOOD := 0
const CAT_KITTEN := 1
const CAT_BAD := 2

const CENTER_X := 96
const CENTER_Y := 210
const CATCH_DX := 20
const CATCH_DY := 18

const MAX_LOAD := 5
const START_HP := 5
const MAX_HP := 5
const PTS_PER_GOODIE := 10
const KITTEN_BONUS := 25
const BARF_PTS := 5
const KITTEN_WEIGHT := 2

const GOAL_BASE := 10
const GOAL_STEP := 5
const SPAWN_BASE := 46
const SPAWN_MIN := 14
const FALL_MIN := 1

const FLASH_HIT := 10
const FLASH_DELIVER := 18
const FLASH_BARF := 40

const FACE_DOWN := 0
const FACE_UP := 1
const FACE_LEFT := 2
const FACE_RIGHT := 3
const ANIM_RATE := 6

# Item type -> category and base fall speed (item_cat / item_fall in config.asm)
const ITEM_CAT := [CAT_GOOD, CAT_GOOD, CAT_KITTEN, CAT_BAD, CAT_BAD, CAT_BAD]
const ITEM_FALL := [1, 1, 1, 1, 1, 1]

# Screen offset: C64 sprite coords -> 320x200 logical pixels
const ORIGIN := Vector2(24, 50)
const FACE_VEC := [Vector2(0, 1), Vector2(0, -1), Vector2(-1, 0), Vector2(1, 0)]

# C64 palette (approx, VICE)
const C_WHITE := Color(1, 1, 1)
const C_ORANGE := Color(0.87, 0.53, 0.33)
const C_LRED := Color(1, 0.47, 0.47)
const C_RED := Color(0.6, 0.0, 0.0)
const C_YELLOW := Color(0.93, 0.93, 0.47)
const C_GREY := Color(0.53, 0.53, 0.53)
const C_DGREY := Color(0.27, 0.27, 0.27)
const C_LGREY := Color(0.73, 0.73, 0.73)
const C_BROWN := Color(0.45, 0.30, 0.05)
const C_CYAN := Color(0.67, 1.0, 0.93)
const C_LGREEN := Color(0.67, 1.0, 0.4)
const C_GREEN := Color(0.0, 0.8, 0.33)
const C_LBLUE := Color(0.2, 0.55, 1.0)
const C_PINK := Color(1.0, 0.6, 0.8)

const ITEM_COLOR := [C_ORANGE, C_LRED, C_YELLOW, C_GREY, C_BROWN, C_CYAN]

# Game states
enum { GS_TITLE, GS_PLAY, GS_INTERLEVEL, GS_OVER }

# ---------------------------------------------------------------------------------------
# Runtime state (vars.asm)
# ---------------------------------------------------------------------------------------
var state := GS_TITLE
var score := 0
var level := 1
var hp := 0
var load := 0
var kittens := 0
var delivered := 0
var goal := 0

var spawn_rate := 0
var spawn_ctr := 0
var fall_base := 1
var bad_weight := 2

var uni_x := 100
var uni_y := 70
var facing := FACE_DOWN
var anim_ctr := 0
var anim_frame := 0

var flash := 0
var parade_x := 24

# Falling items (parallel arrays, slots 0..NUM_ITEMS-1)
var item_active := []
var item_type := []
var item_x := []
var item_y := []
var item_speed := []

# Input edge tracking
var fire_prev := false

var font: Font
var sfx := {}

# ---------------------------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------------------------
func _ready() -> void:
	randomize()
	font = ThemeDB.fallback_font
	item_active.resize(NUM_ITEMS)
	item_type.resize(NUM_ITEMS)
	item_x.resize(NUM_ITEMS)
	item_y.resize(NUM_ITEMS)
	item_speed.resize(NUM_ITEMS)
	_init_audio()
	state = GS_TITLE


# ---------------------------------------------------------------------------------------
# Main loop — one fixed (60 Hz) tick per frame, mirroring the C64 per-frame game loop
# ---------------------------------------------------------------------------------------
func _physics_process(_delta: float) -> void:
	if Input.is_physical_key_pressed(KEY_ESCAPE):
		get_tree().quit()

	var fire := _fire_down()
	var fire_edge := fire and not fire_prev

	match state:
		GS_TITLE:
			if fire_edge:
				game_start()
		GS_PLAY:
			tick_play(fire_edge)
		GS_INTERLEVEL:
			tick_interlevel(fire_edge)
		GS_OVER:
			if fire_edge:
				state = GS_TITLE

	fire_prev = fire
	queue_redraw()


func _fire_down() -> bool:
	return (Input.is_physical_key_pressed(KEY_SPACE)
		or Input.is_physical_key_pressed(KEY_Z)
		or Input.is_physical_key_pressed(KEY_ENTER)
		or Input.is_physical_key_pressed(KEY_KP_ENTER))


# ---------------------------------------------------------------------------------------
# game_start / start_level (game_loop.asm)
# ---------------------------------------------------------------------------------------
func game_start() -> void:
	score = 0
	kittens = 0
	load = 0
	flash = 0
	level = 1
	hp = START_HP
	start_level()
	state = GS_PLAY


func start_level() -> void:
	# goal = GOAL_BASE + (level-1)*GOAL_STEP
	goal = GOAL_BASE + (level - 1) * GOAL_STEP
	delivered = 0

	# spawn_rate = SPAWN_BASE - (level-1)*4, floored at SPAWN_MIN
	spawn_rate = max(SPAWN_BASE - (level - 1) * 4, SPAWN_MIN)
	spawn_ctr = spawn_rate

	# fall_base = FALL_MIN + (level-1)/3, capped at 4
	fall_base = min(FALL_MIN + (level - 1) / 3, 4)

	# bad_weight = 2 + level, capped 9
	bad_weight = min(2 + level, 9)

	for i in NUM_ITEMS:
		item_active[i] = 0

	uni_x = 100
	uni_y = 70
	facing = FACE_DOWN


# ---------------------------------------------------------------------------------------
# Per-frame play tick (game_loop.asm: game_loop)
# ---------------------------------------------------------------------------------------
func tick_play(fire_edge: bool) -> void:
	anim_tick()
	unicorn_update()
	items_update()
	center_check()
	if fire_edge:
		do_barf()
	flash_update()

	if hp == 0:
		state = GS_OVER
		return
	if delivered >= goal:
		parade_x = 24
		state = GS_INTERLEVEL


func tick_interlevel(fire_edge: bool) -> void:
	parade_x += 2
	if parade_x >= 230:
		parade_x = 24
	if fire_edge:
		level += 1
		start_level()
		state = GS_PLAY


# ---------------------------------------------------------------------------------------
# Unicorn (unicorn.asm)
# ---------------------------------------------------------------------------------------
func anim_tick() -> void:
	anim_ctr += 1
	if anim_ctr >= ANIM_RATE:
		anim_ctr = 0
		anim_frame ^= 1


func unicorn_update() -> void:
	if Input.is_physical_key_pressed(KEY_LEFT) or Input.is_physical_key_pressed(KEY_A):
		uni_x = max(uni_x - UNI_SPEED, UNI_X_MIN)
		facing = FACE_LEFT
	if Input.is_physical_key_pressed(KEY_RIGHT) or Input.is_physical_key_pressed(KEY_D):
		uni_x = min(uni_x + UNI_SPEED, UNI_X_MAX)
		facing = FACE_RIGHT
	if Input.is_physical_key_pressed(KEY_UP) or Input.is_physical_key_pressed(KEY_W):
		uni_y = max(uni_y - UNI_SPEED, UNI_Y_MIN)
		facing = FACE_UP
	if Input.is_physical_key_pressed(KEY_DOWN) or Input.is_physical_key_pressed(KEY_S):
		uni_y = min(uni_y + UNI_SPEED, UNI_Y_MAX)
		facing = FACE_DOWN


# ---------------------------------------------------------------------------------------
# Items (items.asm)
# ---------------------------------------------------------------------------------------
func items_update() -> void:
	spawn_ctr -= 1
	if spawn_ctr <= 0:
		item_spawn()
		spawn_ctr = spawn_rate

	for x in NUM_ITEMS:
		if item_active[x] == 0:
			continue
		item_y[x] += item_speed[x]
		if item_y[x] >= ITEM_BOTTOM:
			item_active[x] = 0  # missed off the bottom
			continue
		check_catch(x)


func item_spawn() -> void:
	var x := -1
	for i in NUM_ITEMS:
		if item_active[i] == 0:
			x = i
			break
	if x == -1:
		return  # all slots busy
	var t := pick_type()
	item_type[x] = t
	# x in 40..167 (clear of edges and HUD)
	item_x[x] = (randi() & 0x7F) + 40
	item_y[x] = ITEM_TOP
	# speed = item_fall[type] + (fall_base - FALL_MIN) + (0..1 jitter)
	item_speed[x] = ITEM_FALL[t] + (fall_base - FALL_MIN) + (randi() % 2)
	if item_speed[x] < 1:
		item_speed[x] = 1
	item_active[x] = 1


# pick_type — weighted by bad_weight (out of 16) (util.asm)
func pick_type() -> int:
	var r := randi() % 16
	if r < bad_weight:
		return IT_TOOL + (randi() % 3)
	r -= bad_weight
	if r < KITTEN_WEIGHT:
		return IT_KITTEN
	return randi() % 2  # cake / candy


func check_catch(x: int) -> void:
	if abs(uni_x - item_x[x]) >= CATCH_DX:
		return
	if abs(uni_y - item_y[x]) >= CATCH_DY:
		return
	var cat: int = ITEM_CAT[item_type[x]]
	if cat == CAT_GOOD:
		if load >= MAX_LOAD:
			return  # hands full — let it keep falling
		load += 1
		item_active[x] = 0
		play_sfx("catch")
	elif cat == CAT_KITTEN:
		if kittens < 255:
			kittens += 1
		add_score(KITTEN_BONUS)
		item_active[x] = 0
		play_sfx("catch")
	else:  # CAT_BAD
		item_active[x] = 0
		hit_bad()


func hit_bad() -> void:
	if hp > 0:
		hp -= 1
	flash = FLASH_HIT
	play_sfx("bad")


# center_check — deliver the load at the Good People Center
func center_check() -> void:
	if load == 0:
		return
	if abs(uni_x - CENTER_X) >= CATCH_DX:
		return
	if abs(uni_y - CENTER_Y) >= CATCH_DY:
		return
	add_score(load * PTS_PER_GOODIE)
	delivered += load
	load = 0
	play_sfx("deliver")
	flash = FLASH_DELIVER


# ---------------------------------------------------------------------------------------
# Rainbow barf (barf.asm)
# ---------------------------------------------------------------------------------------
func do_barf() -> void:
	if load == 0:
		return  # need sugar to barf
	load -= 1
	for x in NUM_ITEMS:
		if item_active[x] == 0:
			continue
		if ITEM_CAT[item_type[x]] == CAT_BAD:
			item_active[x] = 0
			add_score(BARF_PTS)
	flash = FLASH_BARF
	play_sfx("barf")


func add_score(n: int) -> void:
	score = min(score + n, 65535)


func flash_update() -> void:
	if flash > 0:
		flash -= 1


# ---------------------------------------------------------------------------------------
# Rendering
# ---------------------------------------------------------------------------------------
func screen_pos(cx: int, cy: int) -> Vector2:
	return Vector2(cx, cy) - ORIGIN


func _draw() -> void:
	match state:
		GS_TITLE:
			draw_title()
		GS_OVER:
			draw_over()
		GS_INTERLEVEL:
			draw_interlevel()
		_:
			draw_play()


func draw_play() -> void:
	# HUD divider
	draw_line(Vector2(240, 0), Vector2(240, 200), C_DGREY, 1.0)
	# Center, unicorn, items
	draw_center(screen_pos(CENTER_X, CENTER_Y))
	for x in NUM_ITEMS:
		if item_active[x] != 0:
			draw_item(item_type[x], screen_pos(item_x[x], item_y[x]))
	draw_unicorn(screen_pos(uni_x, uni_y), anim_frame, facing)
	draw_hud()
	if flash > 0:
		var col := Color.from_hsv(fmod(flash * 0.07, 1.0), 1.0, 1.0)
		draw_rect(Rect2(0, 0, 320, 200), col, false, 2.0)


func draw_hud() -> void:
	var hx := 246
	txt("SCORE", hx, 6, C_CYAN)
	txt("%05d" % score, hx, 16, C_WHITE)
	txt("LOAD", hx, 30, C_GREEN)
	txt("%d/%d" % [load, MAX_LOAD], hx, 40, C_WHITE)
	txt("LIFE", hx, 54, C_LRED)
	for i in MAX_HP:
		var hc := C_LRED if i < hp else C_DGREY
		draw_heart(Vector2(hx + 5 + i * 13, 68), 9.0, hc)
	txt("LEVEL", hx, 78, C_YELLOW)
	txt("%d" % level, hx, 88, C_WHITE)
	txt("KITTY", hx, 102, C_LBLUE)
	txt("%d" % kittens, hx, 112, C_WHITE)
	txt("GOAL", hx, 126, C_ORANGE)
	txt("%d/%d" % [delivered, goal], hx, 136, C_WHITE)


func draw_title() -> void:
	rainbow_title("UNICORN KITTENS", 18)
	txt("sweet deliveries of justice!", 0, 34, C_YELLOW, 8, true)
	var col := C_WHITE
	txt("Fly your unicorn. Catch the falling", 0, 56, col, 7, true)
	txt("cakes, candy and good stuff (hold 5).", 0, 66, col, 7, true)
	txt("Fly them to the Good People Center", 0, 80, col, 7, true)
	txt("to deliver. Rescue kittens enroute!", 0, 90, col, 7, true)
	txt("Dodge tools, poo and email or get hurt.", 0, 100, C_LRED, 7, true)
	txt("*GIMMICK* FIRE = RAINBOW BARF:", 0, 118, C_PINK, 7, true)
	txt("spew rainbows, nuke all the bad stuff!", 0, 128, C_PINK, 7, true)
	txt("Arrows / WASD to fly   SPACE = fire", 0, 150, C_CYAN, 7, true)
	txt("Push FIRE (SPACE) to fly", 0, 168, C_WHITE, 8, true)
	txt("CityXen 2026", 0, 186, C_DGREY, 7, true)


func draw_over() -> void:
	rainbow_title("GAME OVER", 30)
	txt("the unicorn needs a nap.", 0, 60, C_WHITE, 8, true)
	txt("Final score: %05d" % score, 0, 90, C_YELLOW, 8, true)
	txt("Kittens rehomed: %d" % kittens, 0, 108, C_LBLUE, 8, true)
	txt("Push FIRE to fly again", 0, 150, C_WHITE, 8, true)


func draw_interlevel() -> void:
	rainbow_title("LEVEL CLEAR!", 30)
	txt("Kittens rehomed so far: %d" % kittens, 0, 64, C_YELLOW, 8, true)
	txt("the kitties say thank you!", 0, 86, C_WHITE, 8, true)
	draw_item(IT_KITTEN, screen_pos(parade_x, 150))
	txt("Push FIRE for the next level", 0, 170, C_WHITE, 8, true)


func rainbow_title(s: String, y: int) -> void:
	var t := Time.get_ticks_msec() / 1000.0
	var col := Color.from_hsv(fmod(t * 0.3, 1.0), 0.8, 1.0)
	txt(s, 0, y, col, 16, true)


func txt(s: String, x: int, y: int, col: Color, size := 7, center := false, width := 320) -> void:
	var al := HORIZONTAL_ALIGNMENT_CENTER if center else HORIZONTAL_ALIGNMENT_LEFT
	var w := width if center else -1
	draw_string(font, Vector2(x, y + size), s, al, w, size, col)


# ---------------------------------------------------------------------------------------
# Procedural sprite art (placeholders — drawn in a ~22x20 box from top-left)
# ---------------------------------------------------------------------------------------
func tri(a: Vector2, b: Vector2, c: Vector2, col: Color) -> void:
	draw_colored_polygon(PackedVector2Array([a, b, c]), col)


func rainbow_color() -> Color:
	return Color.from_hsv(fmod(Time.get_ticks_msec() / 600.0, 1.0), 0.9, 1.0)


func draw_unicorn(tl: Vector2, f: int, face: int) -> void:
	var c := tl + Vector2(11, 11)
	var dir: Vector2 = FACE_VEC[face]
	var perp := Vector2(-dir.y, dir.x)
	# wings flap with the animation frame
	var wy := -3.0 if f == 0 else 1.0
	tri(c + Vector2(-2, 0), c + Vector2(-11, wy - 4), c + Vector2(-11, wy + 3), C_PINK)
	tri(c + Vector2(2, 0), c + Vector2(11, wy - 4), c + Vector2(11, wy + 3), C_PINK)
	# body + head
	draw_circle(c, 7.0, C_WHITE)
	var hc := c + dir * 6.0
	draw_circle(hc, 4.5, C_WHITE)
	# rainbow mane behind the head
	var m := hc - dir * 4.0
	draw_circle(m + perp * 2.0, 2.0, C_RED)
	draw_circle(m, 2.0, C_YELLOW)
	draw_circle(m - perp * 2.0, 2.0, C_LBLUE)
	# horn (always rainbow)
	tri(hc + dir * 9.0, hc + dir * 3.0 + perp * 2.0, hc + dir * 3.0 - perp * 2.0, rainbow_color())
	# eye
	draw_circle(hc + dir * 1.0 + perp * 1.8, 1.0, Color.BLACK)


func draw_item(t: int, tl: Vector2) -> void:
	match t:
		IT_CAKE:
			draw_rect(Rect2(tl + Vector2(4, 9), Vector2(14, 9)), C_ORANGE)
			draw_rect(Rect2(tl + Vector2(4, 6), Vector2(14, 3)), C_WHITE)
			draw_circle(tl + Vector2(11, 5), 2.0, C_RED)
		IT_CANDY:
			var c := tl + Vector2(11, 11)
			tri(c + Vector2(-5, 0), c + Vector2(-11, -5), c + Vector2(-11, 5), C_LRED)
			tri(c + Vector2(5, 0), c + Vector2(11, -5), c + Vector2(11, 5), C_LRED)
			draw_circle(c, 6.0, C_LRED)
			draw_circle(c, 2.5, C_WHITE)
		IT_KITTEN:
			var c := tl + Vector2(11, 12)
			tri(tl + Vector2(3, 9), tl + Vector2(5, 2), tl + Vector2(9, 8), C_YELLOW)
			tri(tl + Vector2(19, 9), tl + Vector2(17, 2), tl + Vector2(13, 8), C_YELLOW)
			draw_circle(c, 7.0, C_YELLOW)
			draw_circle(c + Vector2(-2.5, -1), 1.0, Color.BLACK)
			draw_circle(c + Vector2(2.5, -1), 1.0, Color.BLACK)
			draw_circle(c + Vector2(0, 1.5), 1.0, C_PINK)
		IT_TOOL:
			draw_rect(Rect2(tl + Vector2(9, 6), Vector2(4, 13)), C_BROWN)  # handle
			draw_rect(Rect2(tl + Vector2(4, 3), Vector2(14, 5)), C_LGREY)  # head
		IT_POO:
			draw_circle(tl + Vector2(11, 16), 6.0, C_BROWN)
			draw_circle(tl + Vector2(11, 11), 4.5, C_BROWN)
			draw_circle(tl + Vector2(11, 7), 3.0, C_BROWN)
			draw_circle(tl + Vector2(9, 9), 1.2, C_WHITE)
			draw_circle(tl + Vector2(13, 9), 1.2, C_WHITE)
		IT_EMAIL:
			draw_rect(Rect2(tl + Vector2(2, 6), Vector2(18, 11)), C_CYAN)
			draw_rect(Rect2(tl + Vector2(2, 6), Vector2(18, 11)), C_DGREY, false, 1.0)
			draw_line(tl + Vector2(2, 6), tl + Vector2(11, 12), C_DGREY, 1.0)
			draw_line(tl + Vector2(20, 6), tl + Vector2(11, 12), C_DGREY, 1.0)


func draw_center(tl: Vector2) -> void:
	# Treats For Good People Center — a little green house with a heart
	draw_rect(Rect2(tl + Vector2(2, 9), Vector2(18, 11)), C_LGREEN)
	tri(tl + Vector2(0, 9), tl + Vector2(11, 1), tl + Vector2(22, 9), C_GREEN)
	draw_rect(Rect2(tl + Vector2(8, 13), Vector2(6, 7)), C_BROWN)  # door
	draw_heart(tl + Vector2(11, 11), 6.0, C_RED)


func draw_heart(pos: Vector2, size: float, col: Color) -> void:
	var r := size * 0.28
	draw_circle(pos + Vector2(-r, -r * 0.3), r, col)
	draw_circle(pos + Vector2(r, -r * 0.3), r, col)
	tri(pos + Vector2(-size * 0.5, r * 0.1), pos + Vector2(size * 0.5, r * 0.1), pos + Vector2(0, size * 0.6), col)


# ---------------------------------------------------------------------------------------
# Audio — tiny synthesised blips, in the spirit of the C64 SID effects (util.asm)
# ---------------------------------------------------------------------------------------
func _init_audio() -> void:
	for fx in ["catch", "bad", "deliver", "barf"]:
		var p := AudioStreamPlayer.new()
		add_child(p)
		sfx[fx] = p
	sfx["catch"].stream = make_tone(660.0, 0.10, "square")
	sfx["bad"].stream = make_tone(120.0, 0.18, "noise")
	sfx["deliver"].stream = make_tone(440.0, 0.16, "square")
	sfx["barf"].stream = make_tone(90.0, 0.35, "noise")


func play_sfx(key: String) -> void:
	if sfx.has(key):
		sfx[key].play()


func make_tone(freq: float, dur: float, wave: String) -> AudioStreamWAV:
	var rate := 22050
	var n := int(rate * dur)
	var data := PackedByteArray()
	data.resize(n * 2)
	for i in n:
		var t := float(i) / rate
		var s := 0.0
		if wave == "noise":
			s = randf() * 2.0 - 1.0
		else:
			s = 1.0 if fmod(t * freq, 1.0) < 0.5 else -1.0
		var env := 1.0 - float(i) / n  # linear decay
		var v := int(clamp(s * env * 0.3, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, v)
	var st := AudioStreamWAV.new()
	st.format = AudioStreamWAV.FORMAT_16_BITS
	st.mix_rate = rate
	st.stereo = false
	st.data = data
	return st
