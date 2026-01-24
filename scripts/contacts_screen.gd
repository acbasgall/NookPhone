extends Control

func _ready():
	# Standardized to lowercase
	var list_node = find_child("contacts_list") 
	
	if list_node == null:
		print("ERROR: contact_list not found. Check your Scene Tree!")
		return
		
	var residents = ConfigLoader.config_data.get("residents", {})
	var home_priority = ConfigLoader.get_system_config().get("home_screen_priority", [])
	
	for id in residents.keys():
		if not id in home_priority:
			create_contact_row(id, residents[id], list_node)

func create_contact_row(id, data, parent):
	var h_box = HBoxContainer.new()
	h_box.add_theme_constant_override("separation", 15)
	h_box.custom_minimum_size.y = 80
	
	# Icon setup
	var tex_rect = TextureRect.new()
	tex_rect.custom_minimum_size = Vector2(60, 60)
	tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	var icon_path = "res://assets/icons/" + data.get("icon", "")
	if FileAccess.file_exists(icon_path):
		tex_rect.texture = load(icon_path)
	
	# Text setup
	var v_box = VBoxContainer.new()
	var name_label = Label.new()
	name_label.text = data.get("name", "Unknown")
	name_label.add_theme_font_size_override("font_size", 20)
	# Using the same brown-grey from the home screen
	name_label.add_theme_color_override("font_color", Color("#5d544b")) 
	
	var role_label = Label.new()
	role_label.text = data.get("role", "Resident")
	role_label.add_theme_font_size_override("font_size", 12)
	role_label.add_theme_color_override("font_color", Color("#5d544b", 0.7)) 
	
	v_box.add_child(name_label)
	v_box.add_child(role_label)
	
	h_box.add_child(tex_rect)
	h_box.add_child(v_box)
	parent.add_child(h_box)

func _on_back_button_pressed():
	# This swaps her back to the main 12-icon grid
	get_tree().change_scene_to_file("res://scenes/nook_phone.tscn")
