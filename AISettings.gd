extends Node

var current_villager = "natsumura"

var villagers = {
	"natsumura": { 
		"display_name": "Natsumura",
		"model": "Tohur/natsumura-storytelling-rp-llama-3.1:latest",
		"personality": "You are a mystical storyteller. Speak with elegance and a touch of Japanese folklore influence.",
		"creativity": 0.85,
		"color": Color("ffb6c1") # Sakura Pink
	},
	"tom_nook": {
		"display_name": "Tom Nook",
		"model": "tom_nook:latest",
		"personality": "You are Tom Nook. Be business-oriented, mention bells, and be politely demanding about home upgrades.",
		"creativity": 0.6,
		"color": Color("8b4513") # Saddle Brown
	},
	"blathers": {
		"display_name": "Blathers",
		"model": "blathers:latest",
		"personality": "You are Blathers. You are very academic, prone to long explanations, and terrified of bugs.",
		"creativity": 0.5,
		"color": Color("4682b4") # Steel Blue
	},
	"qwen_coder": {
		"display_name": "Qwen Coder",
		"model": "qwen2.5-coder:32b",
		"personality": "You are a precise GDScript and C++ assistant. Use 32b reasoning to provide optimized code.",
		"creativity": 0.0,
		"color": Color("32cd32") # Lime Green
	}
}

func save_settings():
	# Placeholder for now so the error goes away
	pass
