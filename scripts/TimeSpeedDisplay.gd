extends Control

# Reference to the Label node
@onready var time_speed_label: Label = $TimeSpeedLabel

# Enable/Disable development mode for debugging
@export var DEV_MODE: bool = false

func _ready():
	if DEV_MODE:
		print("[TimeSpeedDisplay] DEV_MODE: TimeSpeedDisplay is ready.")

	# Use a timer to delay the initial check for the TimeManager singleton
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = 0.2  # Small delay (in seconds)
	timer.connect("timeout", Callable(self, "_initialize_time_speed_display"))
	add_child(timer)
	timer.start()

func _initialize_time_speed_display():
	if DEV_MODE:
		print("[TimeSpeedDisplay] DEV_MODE: Attempting to initialize TimeSpeedDisplay after delay.")
	
	# Directly reference the TimeManager singleton
	if typeof(TimeManager) == TYPE_OBJECT:
		TimeManager.connect("time_speed_changed", Callable(self, "_on_time_speed_changed"))
		if DEV_MODE:
			print("[TimeSpeedDisplay] DEV_MODE: Connected to TimeManager singleton's signal.")
		# Update the label after connecting to the signal
		update_time_speed_label()
	else:
		if DEV_MODE:
			print("[TimeSpeedDisplay] DEV_MODE: TimeManager singleton not found. Retrying...")
		# Retry connecting to TimeManager after another small delay
		var retry_timer = Timer.new()
		retry_timer.one_shot = true
		retry_timer.wait_time = 0.2  # Additional delay to retry
		retry_timer.connect("timeout", Callable(self, "_initialize_time_speed_display"))
		add_child(retry_timer)
		retry_timer.start()

func _on_time_speed_changed(_new_speed: float):
	# Update the label when the time speed changes
	update_time_speed_label()

func update_time_speed_label():
	# Directly reference the TimeManager singleton to get the current time speed
	if typeof(TimeManager) == TYPE_OBJECT:
		time_speed_label.text = "Time Speed: " + str(TimeManager.global_time_speed)
		if DEV_MODE:
			print("[TimeSpeedDisplay] DEV_MODE: Time speed updated to: ", TimeManager.global_time_speed)
	else:
		time_speed_label.text = "Time Speed: N/A"
		if DEV_MODE:
			print("[TimeSpeedDisplay] DEV_MODE: TimeManager singleton not found.")
