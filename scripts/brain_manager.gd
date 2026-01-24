extends Node

# Verified mapping for your /srv vault on the RX 6950 XT
var brain_assignments = {
	"light_brain": "gemma3:4b",      # Fast, lightweight
	"story_brain": "gpt-oss:20b",    # High fidelity narrative
	"heavy_logic_24b": "qwen3-coder:30b", # Complex logic (Nook/Ankha)
	"heavy_logic_32b": "deepseek-r1:32b", # Master logic (Auditor)
	"vision_brain": "qwen3-vl:8b"    # Visual director
}

func get_model_for_type(type: String) -> String:
	return brain_assignments.get(type, "gemma3:4b")
