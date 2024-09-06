extends Node

# Amount by which to change the time speed
@export var changeAmount: float = 0.1

# Enable/Disable development mode for debugging
@export var DEV_MODE: bool = false

# Timer interval for handling input (in seconds)
@export var input_interval: float = 0.1  # You can adjust this value to change the interval between inputs

func _ready():
	if DEV_MODE:
		print("[TimeControls] DEV_MODE: TimeControls ready.")

	# Use a timer to delay the initial check for the TimeManager singleton
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = 0.1  # Small delay (in seconds)
	timer.connect("timeout", Callable(self, "_initialize_time_controls"))
	add_child(timer)
	timer.start()

	# Create a timer to handle input at a fixed interval
	var input_timer = Timer.new()
	input_timer.one_shot = false
	input_timer.wait_time = input_interval
	input_timer.connect("timeout", Callable(self, "handle_input"))
	add_child(input_timer)
	input_timer.start()

func _initialize_time_controls():
	if DEV_MODE:
		print("[TimeControls] DEV_MODE: Attempting to initialize TimeControls after delay.")
	handle_input()

# Function to handle player input
func handle_input():
	# Check if the custom event for decreasing time speed ('Q') is pressed
	if Input.is_action_pressed("time_decrease"):
		change_time_speed(-changeAmount)

	# Check if the custom event for increasing time speed ('E') is pressed
	if Input.is_action_pressed("time_increase"):
		change_time_speed(changeAmount)

# Function to change the time speed in the TimeManager singleton
func change_time_speed(amount: float):
	# Access the TimeManager singleton directly
	if typeof(TimeManager) == TYPE_OBJECT:
		# Update the global time speed
		TimeManager.set_time_speed(TimeManager.global_time_speed + amount)
		if DEV_MODE:
			print("[TimeControls] DEV_MODE: Time speed changed by: ", amount, " New speed: ", TimeManager.global_time_speed)
	else:
		if DEV_MODE:
			print("[TimeControls] DEV_MODE: TimeManager singleton not found.")
