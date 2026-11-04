
extends CanvasLayer
class_name UIManager

signal flashlight_pressed
signal resonance_pressed
signal interact_pressed
signal pause_pressed
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
    process_mode = Node.PROCESS_MODE_ALWAYS

    flashlight_button.pressed.connect(func(): flashlight_pressed.emit())
    resonance_button.pressed.connect(func(): resonance_pressed.emit())
    interact_button.pressed.connect(func(): interact_pressed.emit())
    pause_button.pressed.connect(func(): pause_pressed.emit())
    resume_button.pressed.connect(func(): resume_pressed.emit())
    restart_button.pressed.connect(func(): restart_pressed.emit())

    pause_panel.visible = false
    prompt_label.text = ""
    objective_label.text = "OBJECTIVE"


func set_objective(title: String, _description: String = "") -> void:
    objective_label.text = "OBJECTIVE\n" + title


func set_interaction_prompt(message: String) -> void:
    prompt_label.text = message


func show_message(message: String) -> void:
    prompt_label.text = message


func set_pause_state(value: bool) -> void:
    paused = value
    pause_panel.visible = value


func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_GO_BACK_REQUEST:
        pause_pressed.emit()