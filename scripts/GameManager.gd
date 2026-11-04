
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

    ui.flashlight_pressed.connect(player.toggle_flashlight)
    ui.resonance_pressed.connect(player.toggle_resonance)
    ui.interact_pressed.connect(player.interact)
    ui.pause_pressed.connect(toggle_pause)
    ui.resume_pressed.connect(resume_game)
    ui.restart_pressed.connect(restart_game)

    objective_manager.objective_changed.connect(ui.set_objective)


func show_message(message: String) -> void:
    ui.show_message(message)


func toggle_pause() -> void:
    if is_paused:
        resume_game()
    else:
        pause_game()


func pause_game() -> void:
    if is_paused:
        return

    is_paused = true
    ui.set_pause_state(true)
    get_tree().paused = true
    game_paused.emit()


func resume_game() -> void:
    if not is_paused:
        return

    is_paused = false
    ui.set_pause_state(false)
    get_tree().paused = false
    game_resumed.emit()


func restart_game() -> void:
    is_paused = false
    get_tree().paused = false
    get_tree().reload_current_scene()