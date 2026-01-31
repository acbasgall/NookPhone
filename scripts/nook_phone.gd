extends Control # This fixes Line 30 error

# Declarations to fix Line 4 and Line 19 errors
var residents_data: Dictionary = {}
var current_brain: String = "none"

# Make sure you have a node named "ConfirmationPopup" as a child of this node
# to fix the "$" shorthand errors on Lines 9-12.

func _on_resetti_icon_pressed():
	# Access utility data
	if residents_data.has("utilities"):
		var data = residents_data["utilities"]["resetti"]
		show_confirmation_dialog(data)

func show_confirmation_dialog(data):
	# Using $ requires a child node named ConfirmationPopup
	var popup = $ConfirmationPopup
	popup.get_node("MessageLabel").text = data["warning_text"]
	popup.get_node("ConfirmBtn").text = data["confirm_label"]
	popup.get_node("CancelBtn").text = data["cancel_label"]
	popup.show()

func _on_confirm_shutdown():
	var username = OS.get_environment("USER")
	
	# 1. Kill specific Studio Ports (Harvey: 7860, Kicks: 8188, KK: 5000)
	var ports = ["7860", "8188", "5000"]
	for port in ports:
		# fuser -k finds exactly what is running on that port and kills it
		OS.execute("bash", ["-c", "fuser -k %s/tcp" % port])

	# 2. Kill Ollama (The engine itself)
	OS.execute("pkill", ["-u", username, "ollama"])
	
	# 3. Kill FFmpeg (Stops video/audio rendering)
	OS.execute("pkill", ["-u", username, "ffmpeg"])
	
func list_residents():
	# 1. Clear existing list to prevent duplicates
	for child in $ContactsList/VBox.get_children():
		child.queue_free()
	
	# 2. Access the 'residents' dictionary from your JSON
	var roster = residents_data["residents"]
	
	for id in roster:
		var resident = roster[id]
		
		# 3. Create a new Button for this villager
		var btn = Button.new()
		btn.text = resident["name"] + " (" + resident["role"] + ")"
		
		# 4. Apply their signature color from the JSON
		btn.modulate = Color(resident["color"])
		
		# 5. Connect the button to an 'Open Chat' function
		btn.pressed.connect(_on_resident_selected.bind(id))
		
		# 6. Add it to the UI
		$ContactsList/VBox.add_child(btn)

func _on_resident_selected(resident_id):
	print("Calling: " + resident_id)
	# This is where you'll trigger the Phone-Call/Chat UI
