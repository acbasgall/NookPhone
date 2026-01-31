extends Control

@onready var contacts_list: VBoxContainer = $scroll_container/contacts_list

# PRELOAD the font once to avoid repeated disk access and path errors
const NUNITO_FONT = preload("res://assets/fonts/Nunito-VariableFont_wght.ttf")
const CONTACT_VILLAGERS = ["lolly", "pinky", "raymond", "zucker", "cherry", "roald", "julian", "brewster", "lucky", "pudge", "bluebear"]

func _ready() -> void:
	if ConfigLoader.config_data.is_empty():
		ConfigLoader.load_config()
	_populate_contacts()

func _populate_contacts() -> void:
	for child in contacts_list.get_children():
		child.queue_free()
	
	# 1. THE PROTECTOR: This pushes the list content down
	var top_buffer = Control.new()
	top_buffer.custom_minimum_size = Vector2(0, 40) # Adjust based on status bar height
	contacts_list.add_child(top_buffer)
	
	# Header Spacer
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 0) 
	contacts_list.add_child(spacer)

	create_nav_button("Home", "home.png")

	for id in CONTACT_VILLAGERS:
		create_contact_row(id)
	
	create_nav_button("Home", "home.png")
	
	# Footer Spacer
	var footer = Control.new()
	footer.custom_minimum_size = Vector2(0, 50)
	contacts_list.add_child(footer)
	
	

func create_contact_row(id: String) -> void:
	var data = ConfigLoader.get_resident(id)
	if data.is_empty(): return
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 25)
	margin.add_theme_constant_override("margin_right", 25)
	margin.add_theme_constant_override("margin_bottom", 15)
	
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(0, 100)
	btn.alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	# BANISH THE BOX: Force focus state to be empty
	btn.focus_mode = Control.FOCUS_NONE
	btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(data.get("color", "#ffffff"))
	style.set_corner_radius_all(50) 
	style.shadow_color = Color(0, 0, 0, 0.2)
	style.shadow_size = 6
	style.shadow_offset = Vector2(0, 4)
	style.content_margin_left = 20
	
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style)
	btn.add_theme_stylebox_override("pressed", style)
	
	var icon_path = "res://assets/icons/" + data.get("icon", "")
	if FileAccess.file_exists(icon_path):
		btn.icon = load(icon_path)
		btn.expand_icon = true
		btn.add_theme_constant_override("h_separation", 30)

	btn.text = data.get("name", "")
	btn.add_theme_font_override("font", NUNITO_FONT)
	btn.add_theme_font_size_override("font_size", 30)
	btn.add_theme_constant_override("outline_size", 8)
	btn.add_theme_color_override("font_outline_color", Color.LIGHT_GRAY)
	btn.add_theme_color_override("font_color", Color("#5d544b"))
	
	btn.pressed.connect(func(): _on_resident_selected(id))
	margin.add_child(btn)
	contacts_list.add_child(margin)

func create_nav_button(display_name: String, icon_file: String) -> void:
	var nav_color = "#8db092" 
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 25)
	margin.add_theme_constant_override("margin_right", 25)
	margin.add_theme_constant_override("margin_bottom", 15)
	
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(0, 100)
	btn.alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.text = display_name
	
	# BANISH THE BOX: Force focus state to be empty
	btn.focus_mode = Control.FOCUS_NONE
	btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(nav_color)
	style.set_corner_radius_all(50)
	style.content_margin_left = 20
	
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style)
	
	var icon_path = "res://assets/icons/" + icon_file
	if FileAccess.file_exists(icon_path):
		btn.icon = load(icon_path)
		btn.expand_icon = true
		btn.add_theme_constant_override("h_separation", 30)

	btn.add_theme_font_override("font", NUNITO_FONT)
	btn.add_theme_font_size_override("font_size", 24)
	btn.add_theme_constant_override("outline_size", 8)
	btn.add_theme_color_override("font_outline_color", Color.WHITE)
	btn.add_theme_color_override("font_color", Color("#5d544b"))

	btn.pressed.connect(_on_back_button_pressed)
	margin.add_child(btn)
	contacts_list.add_child(margin)

func _on_resident_selected(id: String) -> void:
	# Triple-Verify: Set the active ID in the singleton before changing scenes
	ResidentManager.active_resident_id = id
	get_tree().change_scene_to_file("res://scenes/chat_screen.tscn")

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/nook_phone.tscn")
