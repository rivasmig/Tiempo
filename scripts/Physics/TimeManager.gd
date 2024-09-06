extends Node

# Default time speed
@export var global_time_speed: float = 1

# Enable/Disable development mode for debugging
@export var DEV_MODE: bool = false

# Signal to notify changes in time speed
signal time_speed_changed(new_speed: float)

func _ready():
	if DEV_MODE:
		print("DEV_MODE: TimeManager is ready!")

	# Use a timer to delay the initial signal emission
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = 0.1  # Small delay (in seconds)
	timer.connect("timeout", Callable(self, "_emit_initial_time_speed"))
	add_child(timer)
	timer.start()

# Emit the initial time speed after a small delay
func _emit_initial_time_speed():
	emit_signal("time_speed_changed", global_time_speed)
	if DEV_MODE:
		print("DEV_MODE: Initial time speed emitted after delay: ", global_time_speed)

# Function to set the global time speed
func set_time_speed(new_speed: float):
	global_time_speed = new_speed
	emit_signal("time_speed_changed", global_time_speed)
	if DEV_MODE:
		print("DEV_MODE: Time speed set to: ", new_speed)
		print("DEV_MODE: Signal time_speed_changed emitted with value: ", new_speed)
