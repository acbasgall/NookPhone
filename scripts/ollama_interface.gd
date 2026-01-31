extends Node
# Simplification: Only one URL, one chat function.
const OLLAMA_URL = "http://localhost:11434"

func chat(model_name: String, message: String, history: Array = []) -> String:
	var url = OLLAMA_URL + "/api/chat"
	var messages = history.duplicate()
	messages.append({"role": "user", "content": message})
	
	var body = JSON.stringify({"model": model_name, "messages": messages, "stream": false})
	var http = HTTPRequest.new()
	add_child(http)
	
	var error = http.request(url, ["Content-Type: application/json"], HTTPClient.METHOD_POST, body)
	if error != OK: return "[Connection Error]"
	
	var response = await http.request_completed
	http.queue_free()
	
	if response[1] != 200: return "[Ollama Error: Check /srv]"
	
	var json = JSON.new()
	json.parse(response[3].get_string_from_utf8())
	return json.data["message"]["content"]
