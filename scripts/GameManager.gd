
extends Node
class_name GameManager

signal game_paused
signal game_resumed

var is_paused: bool = false
var message_timer: float = 0.0

@onready var ui: UIManager = $HUD
@onready var player: CharacterBody3D = $Player


func _ready() -> void:
	add_to_group("GameManager")

	ui.flashlight_pressed.connect(player.toggle_flashlight)
	ui.resonance_pressed.connect(player.toggle_resonance)
	ui.interact_pressed.connect(player.interact)

	var objectives = $ObjectiveManager
	objectives.objective_changed.connect(ui.set_objective)


func show_message(message: String) -> void:
	ui.show_message(message)


func pause_game() -> void:
	if is_paused:
		return

	is_paused = true
	get_tree().paused = true
	game_paused.emit()


func resume_game() -> void:
	if not is_paused:
		return

	is_paused = false
	get_tree().paused = false
	game_resumed.emit()


func restart_game() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
