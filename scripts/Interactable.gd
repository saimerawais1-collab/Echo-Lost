
extends StaticBody3D
class_name Interactable

@export var item_name: String = "Unknown object"
@export_multiline var description: String = "Nothing unusual."
@export var resonance_only: bool = false
@export var interaction_distance: float = 3.0
@export var objective_id: String = ""
@export var one_time_interaction: bool = true

var discovered: bool = false


func can_interact(player: Node3D) -> bool:
	if one_time_interaction and discovered:
		return false

	if resonance_only:
		var resonance = player.get_node_or_null("Camera3D/ResonanceLight")
		if resonance == null or not resonance.visible:
			return false

	return true


func interact(player: Node3D) -> void:
	if not can_interact(player):
		return

	discovered = true

	var game = get_tree().get_first_node_in_group("GameManager")
	if game:
		game.show_message(item_name + "\n" + description)

	if objective_id != "":
		var objectives = get_tree().get_first_node_in_group("ObjectiveManager")
		if objectives:
			objectives.complete_objective(objective_id)
