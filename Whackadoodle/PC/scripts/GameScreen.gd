extends Control

# ─── Button screen positions (centre of each 100×100 button) ─────────────────
#  Layout mirrors the arcade cabinet arrangement:
#           [1-Green]      [3-Blue]
#  [4-White] [0-Red]  [2-Yellow]
const BUTTON_CENTERS := [
	Vector2(290, 410),   # 0 Red
	Vector2(390, 260),   # 1 Green
	Vector2(490, 410),   # 2 Yellow
	Vector2(590, 260),   # 3 Blue
	Vector2(130, 410),   # 4 White
]
const BUTTON_SIZE    := Vector2(100, 100)
const DOODLE_SIZE    := Vector2(110, 110)
const DOODLE_OFFSET  := Vector2(0, -130)   # above the button centre

# ─── State machine ────────────────────────────────────────────────────────────

enum State { GET_READY, WAITING, MESSAGE, DEAD }

var _state          : int   = State.GET_READY
var _doodle_timer   : float = 0.0
var _message_timer  : float = 0.0
var _current_button : int   = -1
var _current_doodle : int   = -1
var _last_button    : int   = -1
var _pending_over   : bool  = false   # game over after message clears

# ─── UI nodes ─────────────────────────────────────────────────────────────────

var _btn_nodes    : Array[Node] = []
var _doodle_rect  : TextureRect
var _score_label  : Label
var _lives_label  : Label
var _message_label: Label
var _mode_label   : Label
var _key_hint     : Label


func _ready() -> void:
	_build_ui()
	_update_hud()
	_show_message("GET READY!", Color.YELLOW, GameData.GETREADY_DURATION)


# ─── Per-frame update ─────────────────────────────────────────────────────────

func _process(delta: float) -> void:
	match _state:
		State.GET_READY, State.MESSAGE:
			_message_timer -= delta
			if _message_timer <= 0.0:
				_message_label.visible = false
				if _pending_over:
					get_tree().root.get_node("Main").show_game_over()
					return
				_setup_next_doodle()

		State.WAITING:
			_doodle_timer -= delta
			if _doodle_timer <= 0.0:
				_handle_timeout()


# ─── Input ────────────────────────────────────────────────────────────────────

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			get_tree().root.get_node("Main").show_attract()
			return
		if _state == State.WAITING:
			for i in GameData.BUTTON_COUNT:
				if event.keycode == GameData.BUTTON_KEYS[i]:
					_on_button_pressed(i)
					return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _state == State.WAITING:
			for i in GameData.BUTTON_COUNT:
				var centre := BUTTON_CENTERS[i]
				var rect   := Rect2(centre - BUTTON_SIZE * 0.5, BUTTON_SIZE)
				if rect.has_point(event.position):
					_on_button_pressed(i)
					return


# ─── Game logic ───────────────────────────────────────────────────────────────

func _setup_next_doodle() -> void:
	# Random button, never the same twice in a row
	var btn := randi() % GameData.BUTTON_COUNT
	while btn == _last_button:
		btn = randi() % GameData.BUTTON_COUNT
	_current_button = btn
	_last_button    = btn

	# Random doodle — easy mode: only doodles 3-6 (star,RAD,skull,poo)
	if GameData.mode == GameData.Mode.EASY:
		_current_doodle = 3 + randi() % 4
	else:
		_current_doodle = randi() % GameData.DOODLE_COUNT

	# Position and show doodle above the active button
	var centre := BUTTON_CENTERS[_current_button]
	var tex    := _try_load_tex(GameData.DOODLE_PATHS[_current_doodle])
	_doodle_rect.texture  = tex
	_doodle_rect.position = centre + DOODLE_OFFSET - DOODLE_SIZE * 0.5
	_doodle_rect.visible  = true

	# Highlight active button, dim others
	for i in GameData.BUTTON_COUNT:
		_btn_nodes[i].modulate = Color.WHITE if i == _current_button else Color(0.35, 0.35, 0.35)

	_doodle_timer = GameData.doodle_time
	_state        = State.WAITING


func _on_button_pressed(button_index: int) -> void:
	if button_index != _current_button:
		# Wrong button → MISS
		_resolve(false, true)
		return

	if GameData.DOODLE_IS_BAD[_current_doodle]:
		# Correct button, bad doodle → POW!
		GameData.score = min(GameData.score + 1, 99)
		_show_message("POW!", Color(0.3, 1.0, 0.3), GameData.MESSAGE_DURATION)
	else:
		# Correct button, good doodle → WRONG!
		GameData.score = max(GameData.score - 1, 0)
		GameData.lives -= 1
		_show_message("WRONG!", Color(1.0, 0.6, 0.1), GameData.MESSAGE_DURATION)

	_clear_doodle()
	_update_hud()
	GameData.advance_speed()
	_check_lives()


func _handle_timeout() -> void:
	if GameData.DOODLE_IS_BAD[_current_doodle]:
		# Missed a bad doodle → MISS
		_resolve(false, false)
	else:
		# Good doodle expired → no penalty, just next round silently
		_clear_doodle()
		GameData.advance_speed()
		_setup_next_doodle()


# _resolve: shared handler for MISS (wrong button or bad-doodle timeout)
func _resolve(_scored: bool, _wrong_button: bool) -> void:
	GameData.lives -= 1
	_show_message("MISS!", Color(1.0, 0.3, 0.3), GameData.MESSAGE_DURATION)
	_clear_doodle()
	_update_hud()
	GameData.advance_speed()
	_check_lives()


func _check_lives() -> void:
	if GameData.lives <= 0:
		_pending_over = true


func _clear_doodle() -> void:
	_current_button   = -1
	_current_doodle   = -1
	_doodle_rect.visible = false
	for btn in _btn_nodes:
		btn.modulate = Color.WHITE


# ─── HUD ─────────────────────────────────────────────────────────────────────

func _update_hud() -> void:
	_score_label.text = "SCORE: %02d" % GameData.score
	_lives_label.text = "♥  ".repeat(GameData.lives).strip_edges()
	_mode_label.text  = GameData.mode_name()


func _show_message(text: String, color: Color, duration: float) -> void:
	_message_label.text = text
	_message_label.add_theme_color_override("font_color", color)
	_message_label.visible = true
	_message_timer = duration
	_state = State.MESSAGE if _state != State.GET_READY else State.GET_READY


# ─── UI construction ──────────────────────────────────────────────────────────

func _build_ui() -> void:
	# Background
	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.04, 0.10)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# ── Header bar ──────────────────────────────────────────────────────────

	var header := ColorRect.new()
	header.color = Color(0.08, 0.08, 0.18)
	header.position = Vector2(0, 0)
	header.size = Vector2(800, 55)
	add_child(header)

	_score_label = _make_label("SCORE: 00", 26, Color.WHITE)
	_score_label.position = Vector2(15, 12)
	_score_label.size = Vector2(220, 35)
	add_child(_score_label)

	_mode_label = _make_label("NORMAL", 22, Color.YELLOW)
	_mode_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_mode_label.position = Vector2(300, 14)
	_mode_label.size = Vector2(200, 30)
	add_child(_mode_label)

	_lives_label = _make_label("♥ ♥ ♥ ♥ ♥ ♥", 22, Color(1.0, 0.35, 0.35))
	_lives_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_lives_label.position = Vector2(480, 12)
	_lives_label.size = Vector2(305, 35)
	add_child(_lives_label)

	# ── Message overlay ──────────────────────────────────────────────────────

	_message_label = _make_label("", 52, Color.WHITE)
	_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message_label.position = Vector2(0, 75)
	_message_label.size = Vector2(800, 80)
	_message_label.visible = false
	add_child(_message_label)

	# ── Doodle display ───────────────────────────────────────────────────────

	_doodle_rect = TextureRect.new()
	_doodle_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	_doodle_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_doodle_rect.size = DOODLE_SIZE
	_doodle_rect.visible = false
	add_child(_doodle_rect)

	# ── Buttons ──────────────────────────────────────────────────────────────

	for i in GameData.BUTTON_COUNT:
		var centre := BUTTON_CENTERS[i]
		var tex    := _try_load_tex(GameData.BUTTON_PATHS[i])
		var node: Node

		if tex:
			var tb := TextureButton.new()
			tb.texture_normal = tex
			tb.ignore_texture_size = true
			tb.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
			tb.size = BUTTON_SIZE
			tb.position = centre - BUTTON_SIZE * 0.5
			tb.pressed.connect(_on_button_pressed.bind(i))
			node = tb
		else:
			# Fallback colored button
			var btn := Button.new()
			btn.text = GameData.BUTTON_NAMES[i][0]   # first letter
			btn.position = centre - BUTTON_SIZE * 0.5
			btn.size = BUTTON_SIZE
			btn.add_theme_font_size_override("font_size", 28)
			var sty := StyleBoxFlat.new()
			sty.bg_color = GameData.BUTTON_COLORS[i]
			sty.corner_radius_top_left     = 12
			sty.corner_radius_top_right    = 12
			sty.corner_radius_bottom_left  = 12
			sty.corner_radius_bottom_right = 12
			btn.add_theme_stylebox_override("normal", sty)
			btn.pressed.connect(_on_button_pressed.bind(i))
			node = btn

		add_child(node)
		_btn_nodes.append(node)

		# Key hint label below each button
		var key_names := ["A", "S", "D", "F", "G"]
		var kl := _make_label("[%s]" % key_names[i], 14, Color(0.55, 0.55, 0.55))
		kl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		kl.position = Vector2(centre.x - 30, centre.y + 56)
		kl.size = Vector2(60, 22)
		add_child(kl)

	# ── Quit hint ────────────────────────────────────────────────────────────

	var quit_lbl := _make_label("ESC = quit", 14, Color(0.4, 0.4, 0.4))
	quit_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	quit_lbl.position = Vector2(670, 575)
	quit_lbl.size = Vector2(120, 20)
	add_child(quit_lbl)



# ─── Helpers ──────────────────────────────────────────────────────────────────

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
