extends Node
# This script handles the "Soul" of the phone by reading residents.json

var config_data: Dictionary = {}

func load_config() -> bool:
	var path = "res://config/residents.json"
	
	if not FileAccess.file_exists(path):
		push_error("Missing residents.json at " + path)
		return false
		
	var file = FileAccess.open(path, FileAccess.READ)
	var json_text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_text)
	
	if error != OK:
		push_error("JSON Parse Error: " + json.get_error_message())
		return false
		
	config_data = json.data
	return true

func get_resident(id: String) -> Dictionary:
	return config_data.get("residents", {}).get(id, {})

func get_system_config() -> Dictionary:
	return config_data.get("system_config", {})
