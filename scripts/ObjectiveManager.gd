
extends Node
class_name ObjectiveManager

signal objective_changed(title: String, description: String)

var objectives: Array[Dictionary] = []
var current_index: int = 0


func _ready() -> void:
	add_to_group("ObjectiveManager")

	objectives = [
		{
			"id": "find_photo",
			"title": "Find Mara's photograph",
			"completed": false
		},
		{
			"id": "find_recorder",
			"title": "Find the old recorder",
			"completed": false
		},
		{
			"id": "activate_echo",
			"title": "Use ECHO to reveal hidden memories",
			"completed": false
		},
		{
			"id": "reach_archive",
			"title": "Find the Archive exit",
			"completed": false
		}
	]

	_update_objective()


func complete_objective(objective_id: String) -> void:
	for i in range(objectives.size()):
		if objectives[i]["id"] == objective_id:
			objectives[i]["completed"] = true

			if i == current_index:
				current_index += 1

			_update_objective()
			return


func _update_objective() -> void:
	while current_index < objectives.size():
		if not objectives[current_index]["completed"]:
			var item = objectives[current_index]
			objective_changed.emit(item["title"], "")
			return

	current_index = objectives.size()
	objective_changed.emit("Chapter complete", "Find the next memory.")
