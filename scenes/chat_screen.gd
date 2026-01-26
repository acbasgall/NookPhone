extends Control

# Verified paths from your hierarchy
@onready var chat_log: VBoxContainer = $vbox/scroll_container/chat_log
@onready var message_input: LineEdit = $vbox/input_area/message_input
@onready var send_button: Button = $vbox/input_area/send_button
@onready var scroll_container: ScrollContainer = $vbox/scroll_container
@onready var voice_player = $animalese_speech
@onready var resident_name_label: Label = $vbox/header/resident_name
# FIX: Added the portrait reference here
@onready var portrait_rect: TextureRect = $vbox/header/portrait 

const VOICE_PATH = "res://assets/voice/Animalese/"
const NUNITO_FONT = preload("res://assets/fonts/Nunito-VariableFont_wght.ttf")

var current_resident_id: String = "lolly" 
var resident_data: Dictionary = {}

func _ready() -> void:
	# Hand-off logic from ResidentManager
	if ResidentManager.active_resident_id != "":
		current_resident_id = ResidentManager.active_resident_id
	
	# Connect signals
	message_input.text_changed.connect(_on_text_changed)
	message_input.text_submitted.connect(_on_message_submitted)
	send_button.pressed.connect(func(): _on_message_submitted(message_input.text))
	
	_style_send_button() # Move styling logic here once, not in scroll loop
	_load_resident_session(current_resident_id)

func _load_resident_session(id: String) -> void:
	resident_data = ConfigLoader.get_resident(id)
	resident_name_label.text = resident_data.get("name", "Resident")
	
	# Update the Header Portrait
	var icon_path = "res://assets/icons/" + resident_data.get("icon", "default.png")
	if FileAccess.file_exists(icon_path):
		portrait_rect.texture = load(icon_path)
	
	_ai_respond("Hey there! Ready to chat?")

func _style_send_button() -> void:
	var send_style = StyleBoxFlat.new()
	send_style.bg_color = Color("#aa96ec") 
	send_style.set_corner_radius_all(10)   
	send_style.content_margin_left = 10
	send_style.content_margin_right = 10

	send_button.add_theme_stylebox_override("normal", send_style)
	send_button.add_theme_stylebox_override("hover", send_style)
	send_button.add_theme_stylebox_override("pressed", send_style)
	send_button.text = "Send"
	send_button.add_theme_color_override("font_color", Color("#ffffff"))

func _on_text_changed(new_text: String) -> void:
	if new_text.is_empty(): return
	var last_char = new_text.right(1).to_lower()
	_play_voice(last_char, 1.2) 

func _on_message_submitted(text: String) -> void:
	if text.strip_edges() == "": return
	
	_add_bubble("Nona", text, true)
	message_input.clear()
	
	await get_tree().create_timer(0.5).timeout
	_ai_respond("That sounds interesting! Tell me more.")

func _ai_respond(full_text: String) -> void:
	var bubble = _add_bubble(resident_data.get("name", "Resident"), "", false)
	
	# TRIPLE-VERIFY: Fixed path to match added margin
	var bubble_label = bubble.get_node("Margin/Label")
	var pitch = resident_data.get("pitch", 1.0)
	
	for i in range(full_text.length()):
		if not is_instance_valid(bubble_label): return
		
		bubble_label.text += full_text[i]
		if full_text[i].strip_edges() != "":
			_play_voice(full_text[i].to_lower(), pitch)
		
		await get_tree().create_timer(0.04).timeout
		_scroll_to_bottom()

func _add_bubble(_sender: String, text: String, is_user: bool) -> PanelContainer:
	var bubble = PanelContainer.new()
	var margin = MarginContainer.new()
	var label = Label.new()

	margin.name = "Margin"
	label.name = "Label"
	
	var style = StyleBoxFlat.new()
	style.set_corner_radius_all(20)
	style.content_margin_left = 15
	style.content_margin_right = 15
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	
	if is_user:
		style.bg_color = Color("#aa96ec") 
		bubble.size_flags_horizontal = Control.SIZE_SHRINK_END 
	else:
		style.bg_color = Color(resident_data.get("color", "#8db092"))
		bubble.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	bubble.add_theme_stylebox_override("panel", style)
	
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", Color("#5d544b"))
	label.add_theme_font_override("font", NUNITO_FONT)
	
	# FIX: Setting sizes on containers, not just label
	bubble.custom_minimum_size.x = 400 
	label.custom_minimum_size.x = 370 # Leave room for margin/padding
	
	bubble.add_child(margin)
	margin.add_child(label)
	chat_log.add_child(bubble)
	
	_scroll_to_bottom()
	return bubble

func _play_voice(c: String, base_pitch: float) -> void:
	if not is_instance_valid(voice_player): return

	var sound_file = c + ".wav"
	var full_path = VOICE_PATH + sound_file
	
	if not FileAccess.file_exists(full_path):
		full_path = VOICE_PATH + "o.wav"
	
	var sfx = load(full_path)
	if sfx:
		if voice_player.playing:
			voice_player.stop()
		
		voice_player.stream = sfx
		voice_player.pitch_scale = base_pitch + randf_range(-0.1, 0.1)
		voice_player.play()

func _scroll_to_bottom() -> void:
	await get_tree().process_frame
	scroll_container.scroll_vertical = int(scroll_container.get_v_scroll_bar().max_value)
