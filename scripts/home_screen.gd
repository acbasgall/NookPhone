extends GridContainer

@onready var voice_player = AudioStreamPlayer.new()

func _ready():
	add_child(voice_player)
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
	# 1. KILL SWITCH: Local flag to stop the loop if the overlay is closed
	var is_active = { "status": true } 
	
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.4)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(overlay)
	
	var bubble = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#5d544b")
	style.set_corner_radius_all(20)
	bubble.add_theme_stylebox_override("panel", style)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_all", 20)
	
	var vbox = VBoxContainer.new()
	var rant_label = Label.new()
	rant_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rant_label.custom_minimum_size = Vector2(350, 0)
	rant_label.text = "" 
	
	var btn_h_box = HBoxContainer.new()
	btn_h_box.alignment = BoxContainer.ALIGNMENT_CENTER
	
	var scram_btn = Button.new()
	scram_btn.text = "SCRAM!"
	scram_btn.disabled = true 
	
	var wait_btn = Button.new()
	wait_btn.text = "WAIT!"
	
	overlay.add_child(bubble)
	bubble.add_child(margin)
	margin.add_child(vbox)
	vbox.add_child(rant_label)
	vbox.add_child(btn_h_box)
	btn_h_box.add_child(wait_btn)
	btn_h_box.add_child(scram_btn)
	
	bubble.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	
	# 4. CONNECTIONS (With the kill switch)
	wait_btn.pressed.connect(func(): 
		is_active["status"] = false # The typewriter will see this and stop
		overlay.queue_free()
	)
	scram_btn.pressed.connect(func(): get_tree().quit())
	
	# 5. THE RANT
	var rant_text = "HEY! YOU!\n\nAre you trying to leave without saving?!\nYou think this is a joke?! \nDon't you 'SCRAM' me!"
	
	for i in range(rant_text.length()):
		# TRIPLE-VERIFY: Check if Nona clicked 'WAIT!' before every character
		if not is_active["status"]: 
			return
		
		rant_label.text += rant_text[i]
		if rant_text[i].strip_edges() != "":
			_play_resetti_voice(rant_text[i].to_lower())
		
		await get_tree().create_timer(0.05).timeout
	
	# Only unlock if she hasn't closed the window already
	if is_instance_valid(scram_btn):
		scram_btn.disabled = false

func _play_resetti_voice(c: String):
	# TRIPLE-VERIFY: Check if the player still exists in memory before touching it
	if not is_instance_valid(voice_player) or voice_player.is_queued_for_deletion():
		return

	var voice_path = "res://assets/voice/Animalese/"
	var sound_file = c + ".wav"
	if not FileAccess.file_exists(voice_path + sound_file):
		sound_file = "o.wav"
		
	var stream = load(voice_path + sound_file)
	if stream:
		voice_player.stream = stream
		voice_player.pitch_scale = 0.6 + randf_range(-0.05, 0.05)
		voice_player.play()

func _on_settings_pressed():
	print("LLOID: Settings...")

func _on_contacts_pressed():
	# This line tells Godot to swap the current screen for the Contacts screen
	var contacts_scene = load("res://scenes/contacts_screen.tscn")
	if contacts_scene:
		get_tree().change_scene_to_packed(contacts_scene)
	else:
		print("ERROR: Could not find ContactsScreen.tscn in res://scenes/")
