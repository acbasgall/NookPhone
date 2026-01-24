extends GridContainer

func _ready():
	if ConfigLoader.config_data.is_empty():
		ConfigLoader.load_config()
	
	await get_tree().process_frame
	
	self.columns = 3
	add_theme_constant_override("h_separation", 28)
	add_theme_constant_override("v_separation", 45) # Increased to account for labels
	
	setup_grid()

func setup_grid():
	for child in get_children():
		child.queue_free()
		
	var priority = ConfigLoader.get_system_config().get("home_screen_priority", [])
	
	for id in priority:
		create_app_button(id)

func create_app_button(id):
	var data = ConfigLoader.get_resident(id)
	if data.is_empty(): return
	
	# VBox to stack Button and Label
	var container = VBoxContainer.new()
	container.add_theme_constant_override("separation", 6)
	
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(115, 115)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(data.get("color", "#ffffff"))
	style.set_corner_radius_all(45)
	style.draw_center = true
	
	# Shadow for depth
	style.shadow_color = Color(0, 0, 0, 0.2)
	style.shadow_size = 4
	style.shadow_offset = Vector2(0, 4)
	
	# FIXED: Manual margins to prevent the crash
	style.content_margin_left = 12
	style.content_margin_top = 12
	style.content_margin_right = 12
	style.content_margin_bottom = 12
	
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style)
	btn.add_theme_stylebox_override("pressed", style)
	btn.add_theme_stylebox_override("focus", style)
	
	var icon_path = "res://assets/icons/" + data.get("icon", "")
	if FileAccess.file_exists(icon_path):
		btn.icon = load(icon_path)
		btn.expand_icon = true
	
# Resident Label
	var label = Label.new()
	label.text = data.get("name", "")
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# THE FONT FIX (Regular version)
	var font_path = "res://assets/fonts/Nunito-Regular.ttf"
	if FileAccess.file_exists(font_path):
		var custom_font = load(font_path)
		label.add_theme_font_override("font", custom_font)
	
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color("#5d544b")) # Warm brown
	
	# ROBUSTNESS: Adding a 2px outline for readability 
	# since we aren't using the Bold variant.
	label.add_theme_constant_override("outline_size", 6)
	label.add_theme_color_override("font_outline_color", Color(1, 1, 1, 0.8)) # Soft white outline
	
	# Router logic
	if id == "resetti":
		btn.pressed.connect(_on_resetti_pressed)
	elif id == "settings":
		btn.pressed.connect(_on_settings_pressed)
	elif id == "contacts":
		btn.pressed.connect(_on_contacts_pressed)
	elif data.has("url"):
		btn.pressed.connect(func(): OS.shell_open(data["url"]))
	else:
		btn.pressed.connect(ResidentManager.start_session.bind(id))
	
	container.add_child(btn)
	container.add_child(label)
	add_child(container)

func _on_resetti_pressed():
	var dialog = ConfirmationDialog.new()
	dialog.title = "RESETTI ALERT"
	dialog.dialog_text = "HEY! YOU! \n\nAre you trying to leave without saving?! \n(This will close the phone app.)"
	dialog.ok_button_text = "SCRAM!"
	dialog.cancel_button_text = "WAIT!"
	
	# THE KILL COMMAND
	dialog.confirmed.connect(func(): get_tree().quit())
	
	# Cleanup memory after the choice is made
	dialog.finished.connect(func(_result): dialog.queue_free())
	
	add_child(dialog)
	dialog.popup_centered()

func _on_settings_pressed():
	print("LLOID: Settings...")

func _on_contacts_pressed():
	# This line tells Godot to swap the current screen for the Contacts screen
	var contacts_scene = load("res://scenes/contacts_screen.tscn")
	if contacts_scene:
		get_tree().change_scene_to_packed(contacts_scene)
	else:
		print("ERROR: Could not find ContactsScreen.tscn in res://scenes/")
