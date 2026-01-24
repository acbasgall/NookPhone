extends Label

func _process(_delta: float) -> void:
	var time = Time.get_time_dict_from_system()
	var hour = time.hour
	var am_pm = "AM" if hour < 12 else "PM"
	
	# Convert 24h to 12h
	if hour == 0: hour = 12
	elif hour > 12: hour -= 12
	
	text = "%d:%02d %s" % [hour, time.minute, am_pm]
	
# The Sunset/Sunrise Logic (6 AM to 6 PM)
	if time.hour >= 6 and time.hour < 18:
		modulate = Color("279a00") # Dark Teal (Daytime)
	else:
		modulate = Color("87ceeb") # Sky Blue (Nighttime)
