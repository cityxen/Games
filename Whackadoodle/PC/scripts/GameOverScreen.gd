extends Control

var _wait_timer : float = 0.0
const AUTO_RETURN := 12.0   # seconds before auto-returning to attract (matches C64 timer 2)


func _ready() -> void:
	_build_ui()


func _process(delta: float) -> void:
	_wait_timer += delta
	if _wait_timer >= AUTO_RETURN:
		_return_to_attract()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		_return_to_attract()
	if event is InputEventMouseButton and event.pressed:
		_return_to_attract()


func _return_to_attract() -> void:
	get_tree().root.get_node("Main").show_attract()


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.04, 0.10)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# "GAME OVER" text
	var go_lbl := _make_label("GAME OVER", 64, Color(1.0, 0.25, 0.25))
	go_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	go_lbl.position = Vector2(0, 120)
	go_lbl.size = Vector2(800, 90)
	add_child(go_lbl)

	# Mode played
	var mode_lbl := _make_label("Mode: " + GameData.mode_name(), 24, Color.YELLOW)
	mode_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mode_lbl.position = Vector2(0, 230)
	mode_lbl.size = Vector2(800, 40)
	add_child(mode_lbl)

	# Score
	var score_lbl := _make_label("SCORE: %02d" % GameData.score, 48, Color.WHITE)
	score_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_lbl.position = Vector2(0, 290)
	score_lbl.size = Vector2(800, 70)
	add_child(score_lbl)

	# Divider
	var div := ColorRect.new()
	div.color = Color(0.3, 0.3, 0.5)
	div.position = Vector2(250, 380)
	div.size = Vector2(300, 2)
	add_child(div)

	# Rating
	var rating := _get_rating()
	var rating_lbl := _make_label(rating, 28, Color(0.8, 0.9, 1.0))
	rating_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rating_lbl.position = Vector2(0, 400)
	rating_lbl.size = Vector2(800, 45)
	add_child(rating_lbl)

	# Press any key prompt
	var press_lbl := _make_label("Press any key to continue", 22, Color(0.55, 0.55, 0.55))
	press_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	press_lbl.position = Vector2(0, 510)
	press_lbl.size = Vector2(800, 35)
	add_child(press_lbl)

	# Logo (small, bottom)
	var logo_tex := _try_load_tex("res://images/whackadoodle!.png")
	if logo_tex:
		var logo := TextureRect.new()
		logo.texture = logo_tex
		logo.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		logo.position = Vector2(300, 555)
		logo.size = Vector2(200, 40)
		add_child(logo)


func _get_rating() -> String:
	var s := GameData.score
	if s >= 90:   return "LEGENDARY  👑"
	if s >= 70:   return "EXCELLENT!"
	if s >= 50:   return "GREAT WORK"
	if s >= 30:   return "GOOD EFFORT"
	if s >= 10:   return "KEEP TRYING"
	return "PRACTICE MORE!"


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
