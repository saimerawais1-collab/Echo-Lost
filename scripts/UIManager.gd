
extends CanvasLayer
class_name UIManager

signal flashlight_pressed
signal resonance_pressed
signal interact_pressed
signal pause_pressed

@onready var objective_label: Label = $ObjectiveLabel
@onready var prompt_label: Label = $InteractionPrompt
@onready var flashlight_button: Button = $FlashlightButton
@onready var resonance_button: Button = $ResonanceButton
@onready var interact_button: Button = $InteractButton
@onready var pause_button: Button = $PauseButton
@onready var pause_panel: Panel = $PausePanel

var paused: bool = false


func _ready() -> void:
	add_to_group("UIManager")

	flashlight_button.pressed.connect(
		func(): flashlight_pressed.emit()
	)

	resonance_button.pressed.connect(
		func(): resonance_pressed.emit()
	)

	interact_button.pressed.connect(
		func(): interact_pressed.emit()
	)

	pause_button.pressed.connect(_toggle_pause)

	pause_panel.visible = false
	prompt_label.text = ""


func set_objective(title: String, _description: String = "") -> void:
	objective_label.text = "OBJECTIVE\n" + title


func set_interaction_prompt(message: String) -> void:
	prompt_label.text = message


func show_message(message: String) -> void:
	prompt_label.text = message


func _toggle_pause() -> void:
	paused = not paused
	pause_panel.visible = paused
	get_tree().paused = paused


func resume_game() -> void:
	paused = false
	pause_panel.visible = false
	get_tree().paused = false


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_toggle_pause()
