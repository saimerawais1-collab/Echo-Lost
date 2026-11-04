
extends Node
class_name InteractionManager

@export var interaction_distance: float = 3.0

var current_target: Interactable = null

@onready var player: CharacterBody3D = get_parent()
@onready var camera: Camera3D = player.get_node("Camera3D")


func _process(_delta: float) -> void:
	_update_target()


func _update_target() -> void:
	current_target = null

	var origin = camera.global_position
	var end = origin - camera.global_transform.basis.z * interaction_distance

	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.exclude = [player]

	var result = player.get_world_3d().direct_space_state.intersect_ray(query)

	if result.is_empty():
		_set_prompt("")
		return

	var collider = result.get("collider")

	if collider is Interactable:
		if collider.can_interact(player):
			current_target = collider
			_set_prompt("USE: " + collider.item_name)
			return

		if collider.resonance_only:
			_set_prompt("Activate ECHO to reveal")
			return

	_set_prompt("")


func interact() -> void:
	if current_target and is_instance_valid(current_target):
		current_target.interact(player)


func _set_prompt(message: String) -> void:
	var ui = get_tree().get_first_node_in_group("UIManager")
	if ui:
		ui.set_interaction_prompt(message)
