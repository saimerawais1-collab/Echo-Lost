
extends StaticBody3D

@export var item_name: String = "Unknown object"
@export_multiline var description: String = "Nothing unusual."
@export var resonance_only: bool = false

var discovered: bool = false


func interact(player: CharacterBody3D) -> void:
	var resonance = player.get_node("Camera3D/ResonanceLight")

	if resonance_only and not resonance.visible:
		player.get_node("../HUD/ObjectiveLabel").text = \
			"Something is hidden. Try activating ECHO."
		return

	discovered = true

	player.get_node("../HUD/ObjectiveLabel").text = \
		item_name + ": " + description
