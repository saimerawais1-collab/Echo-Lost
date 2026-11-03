
extends CharacterBody3D

const SPEED: float = 3.5
const JUMP_VELOCITY: float = 4.5
const LOOK_SENSITIVITY: float = 0.002
const JOYSTICK_RADIUS: float = 100.0

var gravity: float = 9.8
var movement_touch_id: int = -1
var look_touch_id: int = -1
var movement_touch_origin: Vector2 = Vector2.ZERO
var movement_touch_position: Vector2 = Vector2.ZERO

@onready var camera: Camera3D = $Camera3D
@onready var flashlight: SpotLight3D = $Camera3D/Flashlight
@onready var resonance_light: SpotLight3D = $Camera3D/ResonanceLight


func _ready() -> void:
    if not OS.has_feature("mobile"):
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
    if event is InputEventKey:
        if event.pressed and not event.echo:
            if event.keycode == KEY_F:
                flashlight.visible = not flashlight.visible
            elif event.keycode == KEY_R:
                resonance_light.visible = not resonance_light.visible

    elif event is InputEventMouseMotion:
        if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
            _look(event.relative)

    elif event is InputEventScreenTouch:
        if event.pressed:
            var screen_size = get_viewport().get_visible_rect().size

            if event.position.x > screen_size.x * 0.8 \
            and event.position.y < screen_size.y * 0.2:
                flashlight.visible = not flashlight.visible
                return

            if event.position.x > screen_size.x * 0.7 \
            and event.position.y > screen_size.y * 0.7:
                resonance_light.visible = not resonance_light.visible
                return

            if event.position.x < screen_size.x * 0.5:
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

    if input_direction.length() > 1.0:
        input_direction = input_direction.normalized()

    if movement_touch_id != -1:
        var touch_vector = (
            movement_touch_position - movement_touch_origin
        ) / JOYSTICK_RADIUS

        return touch_vector.limit_length(1.0)

    return input_direction


func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= gravity * delta

    if Input.is_action_just_pressed("ui_accept") and is_on_floor():
        velocity.y = JUMP_VELOCITY

    var input_direction = _get_movement_input()

    var direction = (
        transform.basis * Vector3(input_direction.x, 0, input_direction.y)
    ).normalized()

    if direction:
        velocity.x = direction.x * SPEED
        velocity.z = direction.z * SPEED
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)
        velocity.z = move_toward(velocity.z, 0, SPEED)

    move_and_slide()
