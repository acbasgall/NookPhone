extends TextureProgressBar

@export_group("Testing")
@export var use_test_slider: bool = true
@export_range(0, 100) var test_ram_free: float = 8

func _process(_delta: float) -> void:
	var ram_percent_free: float = 0.0
	
	if use_test_slider:
		# Use the slider in the Inspector
		ram_percent_free = test_ram_free
	else:
		# TRIPLE-VERIFY: Real Linux Data
		var mem_info = FileAccess.get_file_as_string("/proc/meminfo")
		var total_mem = 1.0
		var avail_mem = 0.0
		for line in mem_info.split("\n"):
			if "MemTotal" in line:
				total_mem = float(line.split(":")[1].strip_edges().split(" ")[0])
			if "MemAvailable" in line:
				avail_mem = float(line.split(":")[1].strip_edges().split(" ")[0])
				break
		ram_percent_free = (avail_mem / total_mem) * 100.0

	# 2. PIXEL-CALIBRATED LOGIC (Head=65, <<<=40, <<=20)
	if ram_percent_free > 75:
		value = 100             # Full Icon
		self_modulate = Color("32cd32") # Green
	elif ram_percent_free > 50:
		value = 65              # Head Gone
		self_modulate = Color("32cd32") # Green
	elif ram_percent_free > 25:
		value = 40              # <<< Gone
		self_modulate = Color("ffaf4d") # Yellow
	elif ram_percent_free > 10:
		value = 20              # << Gone
		self_modulate = Color("ff4500") # Red
	else:
		value = 100             # Panic Mode: Full & Solid Red
		self_modulate = Color("ff0000") 

	# 3. SLOW PANIC PULSE & CUSTOM SOUND
	if ram_percent_free <= 10:
		# SLOWER: 120 frames is a 2-second cycle at 60fps
		var pulse_frame = Engine.get_frames_drawn() % 120
		
		# Visual Pulse: On for the first 60 frames, Dim for the next 60
		modulate.a = 1.0 if pulse_frame < 60 else 0.3
		
		# Sound Trigger
		if pulse_frame == 0:
			if $PanicSound.stream != null:
				# --- ADJUST THESE TWO LINES FOR THE 'FEEL' ---
				$PanicSound.pitch_scale = 1.1 # Higher for 'Panic', Lower for 'Dread'
				$PanicSound.volume_db = 0.0   # 0 is full, negative is quieter
				# ---------------------------------------------
				$PanicSound.play()
	else:
		modulate.a = 1.0
		if $PanicSound.playing:
			$PanicSound.stop()
