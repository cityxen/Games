extends Control

# ─── Layout constants ─────────────────────────────────────────────────────────

const SCREEN_W := 800
const SCREEN_H := 600

const LOGO_Y      := 30
const LOGO_H      := 120

const DOODLE_ROW_Y   := 200
const DOODLE_SIZE    := Vector2(70, 70)
const DOODLE_SPACING := 85

const HINT_Y     := 310
const MODE_Y     := 380
const MODE_BTN_W := 160
const MODE_BTN_H := 55
const KEYS_Y     := 500

# ─── State ────────────────────────────────────────────────────────────────────

var _flash_timer  : float = 0.0
var _rotate_timer : float = 0.0
var _page         : int   = 0        # 0 = title, 1 = instructions

var _title_group : Control
var _instr_group : Control

var _flash_buttons : Array = []      # ColorRect overlays that flash


func _ready() -> void:
	_build_ui()
	_show_page(0)


func _process(delta: float) -> void:
	_flash_timer += delta
	if _flash_timer >= 0.8:
		_flash_timer = 0.0
		_do_random_flash()

	_rotate_timer += delta
	if _rotate_timer >= 4.0:
		_rotate_timer = 0.0
		_page = (_page + 1) % 2
		_show_page(_page)


func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match event.keycode:
		KEY_1, KEY_E:
			_start(GameData.Mode.EASY)
		KEY_2, KEY_N, KEY_ENTER, KEY_SPACE:
			_start(GameData.Mode.NORMAL)
		KEY_3, KEY_H:
			_start(GameData.Mode.HARD)


# ─── UI construction ──────────────────────────────────────────────────────────

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.04, 0.10)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# ── Title page ──────────────────────────────────────────────────────────

	_title_group = Control.new()
	_title_group.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_title_group)

	var logo_tex := _try_load_tex("res://images/whackadoodle!.png")
	if logo_tex:
		var logo := TextureRect.new()
		logo.texture = logo_tex
		logo.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		logo.position = Vector2(100, LOGO_Y)
		logo.size = Vector2(600, LOGO_H)
		_title_group.add_child(logo)
	else:
		var lbl := _make_label("WHACKADOODLE!", 48, Color.YELLOW)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.position = Vector2(0, LOGO_Y + 20)
		lbl.size = Vector2(SCREEN_W, 80)
		_title_group.add_child(lbl)

	var sub := _make_label("by Deadline / CityXen", 20, Color(0.6, 0.6, 0.6))
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.position = Vector2(0, LOGO_Y + LOGO_H + 10)
	sub.size = Vector2(SCREEN_W, 30)
	_title_group.add_child(sub)

	# Row of button images that can flash
	var btn_total_w := 5 * 80 + 4 * 20
	var btn_start_x := (SCREEN_W - btn_total_w) / 2
	for i in GameData.BUTTON_COUNT:
		var tex := _try_load_tex(GameData.BUTTON_PATHS[i])
		var bx := btn_start_x + i * 100
		var by := 300
		if tex:
			var tr := TextureRect.new()
			tr.texture = tex
			tr.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
			tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tr.position = Vector2(bx, by)
			tr.size = Vector2(80, 80)
			_title_group.add_child(tr)
		else:
			var cr := ColorRect.new()
			cr.color = GameData.BUTTON_COLORS[i]
			cr.position = Vector2(bx, by)
			cr.size = Vector2(80, 80)
			_title_group.add_child(cr)
			_flash_buttons.append(cr)

	_add_mode_buttons(_title_group, 420)

	var keys_hint := _make_label("E = Easy   N / Enter = Normal   H = Hard", 16, Color(0.5, 0.5, 0.5))
	keys_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	keys_hint.position = Vector2(0, 540)
	keys_hint.size = Vector2(SCREEN_W, 30)
	_title_group.add_child(keys_hint)

	# ── Instructions page ────────────────────────────────────────────────────

	_instr_group = Control.new()
	_instr_group.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_instr_group)

	var title2 := _make_label("HOW TO PLAY", 32, Color.YELLOW)
	title2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title2.position = Vector2(0, 30)
	title2.size = Vector2(SCREEN_W, 50)
	_instr_group.add_child(title2)

	var good_lbl := _make_label("GOOD — don't hit!", 18, Color(0.3, 1.0, 0.3))
	good_lbl.position = Vector2(60, 100)
	good_lbl.size = Vector2(300, 30)
	_instr_group.add_child(good_lbl)

	var bad_lbl := _make_label("BAD — HIT THEM!", 18, Color(1.0, 0.3, 0.3))
	bad_lbl.position = Vector2(430, 100)
	bad_lbl.size = Vector2(300, 30)
	_instr_group.add_child(bad_lbl)

	for i in GameData.DOODLE_COUNT:
		var tex := _try_load_tex(GameData.DOODLE_PATHS[i])
		var col := i % 4
		var row := i / 4
		var x := 60 + col * 90 + (370 if row == 1 else 0)
		var y := 140
		if tex:
			var tr := TextureRect.new()
			tr.texture = tex
			tr.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
			tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tr.position = Vector2(x, y)
			tr.size = Vector2(70, 70)
			_instr_group.add_child(tr)
		else:
			var lbl := _make_label("?", 32, Color.WHITE)
			lbl.position = Vector2(x + 20, y + 10)
			lbl.size = Vector2(50, 50)
			_instr_group.add_child(lbl)

	var lines := [
		"A button lights up — a Doodle appears above it.",
		"Press the matching key or click the button.",
		"Hit BAD Doodles for +1 score.",
		"Hitting GOOD Doodles costs a life and 1 point.",
		"Wrong button or timeout on BAD = lose a life.",
	]
	for li in lines.size():
		var ll := _make_label(lines[li], 17, Color(0.85, 0.85, 0.85))
		ll.position = Vector2(60, 240 + li * 34)
		ll.size = Vector2(680, 30)
		_instr_group.add_child(ll)

	var kbd := _make_label("Keys:  A = Red   S = Green   D = Yellow   F = Blue   G = White", 16, Color(0.6, 0.8, 1.0))
	kbd.position = Vector2(60, 430)
	kbd.size = Vector2(680, 30)
	_instr_group.add_child(kbd)

	_add_mode_buttons(_instr_group, 470)


func _add_mode_buttons(parent: Control, y: float) -> void:
	var configs := [
		["EASY",   Color(1.0, 0.3, 0.3), GameData.Mode.EASY],
		["NORMAL", Color(1.0, 1.0, 0.3), GameData.Mode.NORMAL],
		["HARD",   Color(0.3, 0.5, 1.0), GameData.Mode.HARD],
	]
	var total_w := configs.size() * (MODE_BTN_W + 20) - 20
	var start_x := (SCREEN_W - total_w) / 2.0

	for ci in configs.size():
		var cfg = configs[ci]
		var btn := Button.new()
		btn.text = cfg[0]
		btn.position = Vector2(start_x + ci * (MODE_BTN_W + 20), y)
		btn.size = Vector2(MODE_BTN_W, MODE_BTN_H)
		btn.add_theme_font_size_override("font_size", 22)
		btn.add_theme_color_override("font_color", Color.BLACK)
		var style := StyleBoxFlat.new()
		style.bg_color = cfg[1]
		style.corner_radius_top_left     = 8
		style.corner_radius_top_right    = 8
		style.corner_radius_bottom_left  = 8
		style.corner_radius_bottom_right = 8
		btn.add_theme_stylebox_override("normal", style)
		var hover := style.duplicate() as StyleBoxFlat
		hover.bg_color = cfg[1].lightened(0.2)
		btn.add_theme_stylebox_override("hover", hover)
		btn.pressed.connect(_start.bind(cfg[2]))
		parent.add_child(btn)


# ─── Helpers ──────────────────────────────────────────────────────────────────

func _show_page(p: int) -> void:
	_title_group.visible = (p == 0)
	_instr_group.visible = (p == 1)


func _do_random_flash() -> void:
	if _flash_buttons.is_empty():
		return
	for fb in _flash_buttons:
		fb.visible = false
	var pick := randi() % _flash_buttons.size()
	_flash_buttons[pick].visible = true


func _start(mode: int) -> void:
	get_tree().root.get_node("Main").start_game(mode)


func _try_load_tex(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null


func _make_label(text: String, font_size: int, color: Color) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", font_size)
	lbl.add_theme_color_override("font_color", color)
	return lbl
