extends Node

var active_resident_id: String = ""

func start_session(id: String) -> void:
	active_resident_id = id
	
	# 1. Get Resident Data
	var data = ConfigLoader.get_resident(id)
	
	# 2. Determine Brain (Logic from residents.json)
	var brain_type = data.get("brain", "light_brain") 
	var model = BrainManager.get_model_for_type(brain_type)
	
	print("ResidentManager: Loading ", id, " with brain: ", model)
	
	# 3. Transition to Chat
	get_tree().change_scene_to_file("res://scenes/chat_screen.tscn")
