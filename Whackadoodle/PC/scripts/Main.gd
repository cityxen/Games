extends Node

const ATTRACT_SCENE   := preload("res://scenes/AttractScreen.tscn")
const GAME_SCENE      := preload("res://scenes/GameScreen.tscn")
const GAME_OVER_SCENE := preload("res://scenes/GameOverScreen.tscn")

var _current: Node = null


func _ready() -> void:
	show_attract()


func show_attract() -> void:
	_switch_to(ATTRACT_SCENE.instantiate())


func start_game(mode: int) -> void:
	GameData.reset(mode)
	_switch_to(GAME_SCENE.instantiate())


func show_game_over() -> void:
	_switch_to(GAME_OVER_SCENE.instantiate())


func _switch_to(scene: Node) -> void:
	if _current:
		remove_child(_current)
		_current.queue_free()
	_current = scene
	add_child(scene)
