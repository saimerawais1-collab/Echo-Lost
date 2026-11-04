
extends CanvasLayer
class_name UIManager

signal flashlight_pressed
signal resonance_pressed
signal interact_pressed
signal resume_pressed
signal restart_pressed

@onready var objective_label: Label = $ObjectiveLabel
@onready var prompt_label: Label = $InteractionPrompt

@onready var flashlight_button: Button = $FlashlightButton
@onready var resonance_button: Button = $ResonanceButton
@onready var interact_button: Button = $InteractButton
@onready var pause_button: Button = $PauseButton

@onready var pause_panel: Panel = $PausePanel
@onready var resume_button: Button = $PausePanel/ResumeButton
@onready var restart_button: Button = $PausePanel/RestartButton

var paused: bool = false


func _ready() -> void:
	add_to_group("UIManager")

	# UI remains active while the game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

	flashlight_button.pressed.connect(_on_flashlight_pressed)
	resonance_button.pressed.connect(_on_resonance_pressed)
	interact_button.pressed.connect(_on_interact_pressed)
	pause_button.pressed.connect(_toggle_pause)

	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)

	pause_panel.visible = false
	prompt_label.text = ""
	objective_label.text = "OBJECTIVE"


func _on_flashlight_pressed() -> void:
	flashlight_pressed.emit()


func _on_resonance_pressed() -> void:
	resonance_pressed.emit()


func _on_interact_pressed() -> void:
	interact_pressed.emit()


func set_objective(title: String, _description: String = "") -> void:
	objective_label.text = "OBJECTIVE\n" + title


func set_interaction_prompt(message: String) -> void:
	prompt_label.text = message


func show_message(message: String) -> void:
	prompt_label.text = message


func _toggle_pause() -> void:
	if paused:
		resume_game()
	else:
		pause_game()


func pause_game() -> void:
	if paused:
		return

	paused = true
	pause_panel.visible = true
	get_tree().paused = true


func resume_game() -> void:
	paused = false
	pause_panel.visible = false
	get_tree().paused = false
	resume_pressed.emit()


func restart_game() -> void:
	paused = false
	pause_panel.visible = false
	get_tree().paused = false
	restart_pressed.emit()


func _on_resume_pressed() -> void:
	resume_game()


func _on_restart_pressed() -> void:
	restart_game()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_toggle_pause()
