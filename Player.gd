

extends CharacterBody3D

const SPEED: float = 3.5
const JUMP_VELOCITY: float = 4.5
const LOOK_SENSITIVITY: float = 0.003
const JOYSTICK_RADIUS: float = 100.0
const ACCELERATION: float = 12.0
const DECELERATION: float = 15.0

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var movement_touch_id: int = -1
var look_touch_id: int = -1
var movement_touch_origin: Vector2 = Vector2.ZERO
var movement_touch_position: Vector2 = Vector2.ZERO

@onready var camera: Camera3D = $Camera3D
@onready var flashlight: SpotLight3D = $Camera3D/Flashlight
@onready var resonance_light: SpotLight3D = $Camera3D/ResonanceLight

@onready var flashlight_button: Button = $"../HUD/FlashlightButton"
@onready var resonance_button: Button = $"../HUD/ResonanceButton"
@onready var interact_button: Button = $"../HUD/InteractButton"
@onready var objective_label: Label = $"../HUD/ObjectiveLabel"


func _ready() -> void:
	if not OS.has_feature("mobile"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	flashlight.light_energy = 4.5
	flashlight.spot_range = 18.0
	flashlight.spot_angle = 50.0
	flashlight.shadow_enabled = false

	resonance_light.light_energy = 3.5
	resonance_light.spot_range = 12.0
	resonance_light.spot_angle = 45.0
	resonance_light.shadow_enabled = false

	flashlight_button.pressed.connect(_toggle_flashlight)
	resonance_button.pressed.connect(_toggle_resonance)
	interact_button.pressed.connect(_interact)


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and not event.echo:
			match event.keycode:
				KEY_F:
					_toggle_flashlight()
				KEY_R:
					_toggle_resonance()
				KEY_E:
					_interact()

	elif event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			_look(event.relative)

	elif event is InputEventScreenTouch:
		if event.pressed:
			var screen_size = get_viewport().get_visible_rect().size

			# UI buttons are handled by their own signals.
			if event.position.x > screen_size.x * 0.75:
				return

			if event.position.x < screen_size.x * 0.45:
				if movement_touch_id == -1:
					movement_touch_id = event.index
					movement_touch_origin = event.position
					movement_touch_position = event.position
			else:
				if look_touch_id == -1:
					look_touch_id = event.index
		else:
			if event.index == movement_touch_id:
				movement_touch_id = -1

			if event.index == look_touch_id:
				look_touch_id = -1

	elif event is InputEventScreenDrag:
		if event.index == movement_touch_id:
			movement_touch_position = event.position
		elif event.index == look_touch_id:
			_look(event.relative)


func _toggle_flashlight() -> void:
	flashlight.visible = not flashlight.visible
	flashlight_button.text = "LIGHT ON" if flashlight.visible else "LIGHT OFF"


func _toggle_resonance() -> void:
	resonance_light.visible = not resonance_light.visible
	resonance_button.text = "ECHO ON" if resonance_light.visible else "ECHO OFF"


func _look(relative: Vector2) -> void:
	rotate_y(-relative.x * LOOK_SENSITIVITY)
	camera.rotate_x(-relative.y * LOOK_SENSITIVITY)
	camera.rotation.x = clamp(camera.rotation.x, -1.5, 1.5)


func _get_movement_input() -> Vector2:
	var input_direction = Input.get_vector(
		"ui_left", "ui_right", "ui_up", "ui_down"
	)

	if Input.is_key_pressed(KEY_A):
		input_direction.x -= 1.0
	if Input.is_key_pressed(KEY_D):
		input_direction.x += 1.0
	if Input.is_key_pressed(KEY_W):
		input_direction.y -= 1.0
	if Input.is_key_pressed(KEY_S):
		input_direction.y += 1.0

	if movement_touch_id != -1:
		var touch_vector = (
			movement_touch_position - movement_touch_origin
		) / JOYSTICK_RADIUS

		return touch_vector.limit_length(1.0)

	return input_direction.limit_length(1.0)


func _interact() -> void:
	objective_label.text = "Nothing to interact with nearby."


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = JUMP_VELOCITY

	var input_direction = _get_movement_input()

	var direction = (
		transform.basis * Vector3(input_direction.x, 0, input_direction.y)
	).normalized()

	if direction:
		velocity.x = move_toward(
			velocity.x, direction.x * SPEED, ACCELERATION * delta
		)
		velocity.z = move_toward(
			velocity.z, direction.z * SPEED, ACCELERATION * delta
		)
	else:
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)
		velocity.z = move_toward(velocity.z, 0, DECELERATION * delta)

	move_and_slide()
