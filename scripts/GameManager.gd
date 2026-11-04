
extends Node
class_name GameManager

signal game_paused
signal game_resumed

var is_paused: bool = false

@onready var ui: UIManager = $HUD
@onready var player: HorrorPlayer = $Player
@onready var objective_manager: ObjectiveManager = $ObjectiveManager


func _ready() -> void:
	add_to_group("GameManager")

	# Connect mobile HUD controls
	if ui and player:
		ui.flashlight_pressed.connect(player.toggle_flashlight)
		ui.resonance_pressed.connect(player.toggle_resonance)
		ui.interact_pressed.connect(player.interact)

	# Connect objective updates to HUD
	if objective_manager and ui:
		objective_manager.objective_changed.connect(ui.set_objective)

	# Connect pause menu controls
	if ui:
		ui.resume_pressed.connect(resume_game)
		ui.restart_pressed.connect(restart_game)


func show_message(message: String) -> void:
	if ui:
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
	is_paused = false
	get_tree().paused = false
	get_tree().reload_current_scene()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if is_paused:
			resume_game()
		else:
			pause_game()
