extends Node
# Simplification: Just holds the active villager state.
var active_resident_id: String = ""
var chat_histories: Dictionary = {}

func start_session(resident_id: String):
	active_resident_id = resident_id
	if not chat_histories.has(resident_id):
		chat_histories[resident_id] = []
