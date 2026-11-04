
extends CharacterBody3D
class_name HorrorPlayer

const WALK_SPEED := 3.5
const CROUCH_SPEED := 1.5
const JUMP_VELOCITY := 4.0
const LOOK_SENSITIVITY := 0.003
const JOYSTICK_RADIUS := 90.0
const ACCELERATION := 12.0
const DECELERATION := 15.0

var gravity: float = ProjectSettings.get_setting(
	"physics/3d/default_gravity"
)

var movement_touch_id := -1
var look_touch_id := -1
var movement_origin := Vector2.ZERO
var movement_position := Vector2.ZERO

var crouching := false

@onready var camera: Camera3D = $Camera3D
@onready var flashlight: SpotLight3D = $Camera3D/Flashlight
@onready var resonance_light: SpotLight3D = $Camera3D/ResonanceLight
@onready var interaction_manager: InteractionManager = $InteractionManager


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


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_F:
				toggle_flashlight()
			KEY_R:
				toggle_resonance()
			KEY_E:
				interact()
			KEY_C:
				toggle_crouch()
			KEY_ESCAPE:
				get_tree().get_first_node_in_group("GameManager").pause_game()

	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			_look(event.relative)

	if event is InputEventScreenTouch:
		if event.pressed:
			var size = get_viewport().get_visible_rect().size

			if event.position.x < size.x * 0.45:
				if movement_touch_id == -1:
					movement_touch_id = event.index
					movement_origin = event.position
					movement_position = event.position
			else:
				if look_touch_id == -1:
					look_touch_id = event.index
		else:
			if event.index == movement_touch_id:
				movement_touch_id = -1
			if event.index == look_touch_id:
				look_touch_id = -1

	if event is InputEventScreenDrag:
		if event.index == movement_touch_id:
			movement_position = event.position
		elif event.index == look_touch_id:
			_look(event.relative)


func toggle_flashlight() -> void:
	flashlight.visible = not flashlight.visible


func toggle_resonance() -> void:
	resonance_light.visible = not resonance_light.visible


func toggle_crouch() -> void:
	crouching = not crouching


func interact() -> void:
	interaction_manager.interact()


func _look(relative: Vector2) -> void:
	rotate_y(-relative.x * LOOK_SENSITIVITY)
	camera.rotate_x(-relative.y * LOOK_SENSITIVITY)
	camera.rotation.x = clamp(camera.rotation.x, -1.5, 1.5)


func _movement_input() -> Vector2:
	var input_vector := Input.get_vector(
		"ui_left", "ui_right", "ui_up", "ui_down"
	)

	if movement_touch_id != -1:
		var touch_vector = (
			movement_position - movement_origin
		) / JOYSTICK_RADIUS

		return touch_vector.limit_length(1.0)

	return input_vector.limit_length(1.0)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_vector = _movement_input()
	var speed = CROUCH_SPEED if crouching else WALK_SPEED

	var direction = (
		transform.basis * Vector3(
			input_vector.x, 0, input_vector.y
		)
	).normalized()

	if direction:
		velocity.x = move_toward(
			velocity.x, direction.x * speed, ACCELERATION * delta
		)
		velocity.z = move_toward(
			velocity.z, direction.z * speed, ACCELERATION * delta
		)
	else:
		velocity.x = move_toward(
			velocity.x, 0, DECELERATION * delta
		)
		velocity.z = move_toward(
			velocity.z, 0, DECELERATION * delta
		)

	move_and_slide()
