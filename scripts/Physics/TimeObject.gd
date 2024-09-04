extends Node3D

# Time manipulation variable
var time_speed: float = 1.0

# Enable/Disable development mode for debugging
@export var DEV_MODE: bool = false

# Reference to the custom GravityRigidBody
@onready var target_physics_body: GravityRigidBody = get_child_gravity_rigidbody()

# Store the original velocity for calculation
var original_velocity: Vector3 = Vector3.ZERO
var original_angular_velocity: Vector3 = Vector3.ZERO

# Flags to avoid excessive logging
var has_logged_initial_velocity = false

func _ready():
	# Check if a valid GravityRigidBody is attached
	if not target_physics_body:
		push_warning("TimeObject requires a GravityRigidBody as a child node!")
		if DEV_MODE:
			print("[TimeObject] DEV_MODE: No GravityRigidBody found as a child of ", self.name)
	else:
		if DEV_MODE:
			print("[TimeObject] DEV_MODE: Found GravityRigidBody child: ", target_physics_body.name)

	# Correctly reference the TimeManager singleton
	if TimeManager:
		TimeManager.connect("time_speed_changed", Callable(self, "_on_time_speed_changed"))
		if DEV_MODE:
			print("[TimeObject] DEV_MODE: Connected to TimeManager singleton's signal.")

		# Manually request current time speed from TimeManager after connecting
		_on_time_speed_changed(TimeManager.global_time_speed)
	else:
		if DEV_MODE:
			print("[TimeObject] DEV_MODE: TimeManager singleton not found!")

func _physics_process(delta):
	# Apply time manipulation after all external forces have been calculated
	apply_time_manipulation()

# Function to apply time manipulation to the physics body
func apply_time_manipulation():
	if not target_physics_body:
		if DEV_MODE:
			print("[TimeObject] DEV_MODE: Cannot apply time manipulation, no target physics body.")
		return

	if target_physics_body is GravityRigidBody:
		var rigid_body = target_physics_body as GravityRigidBody

		# Apply time speed scaling to linear and angular velocity
		var speed_multiplier = abs(time_speed)
		if time_speed < 0:
			rigid_body.linear_velocity = -rigid_body.linear_velocity
			rigid_body.angular_velocity = -rigid_body.angular_velocity
			if DEV_MODE:
				print("[TimeObject] DEV_MODE: Negative time speed, reversing direction.")
		rigid_body.linear_velocity *= speed_multiplier
		rigid_body.angular_velocity *= speed_multiplier
		if DEV_MODE:
			print("[TimeObject] DEV_MODE: Applied time speed multiplier. Linear:", rigid_body.linear_velocity, "Angular:", rigid_body.angular_velocity)
		
# Handle global time speed changes from the singleton
func _on_time_speed_changed(new_speed: float):
	if DEV_MODE:
		print("[TimeObject] DEV_MODE: Time speed changed to: ", new_speed)
	time_speed = new_speed
	# Store original velocity to use for adjustments
	if target_physics_body:
		if target_physics_body is GravityRigidBody:
			var rigid_body = target_physics_body as GravityRigidBody
			original_velocity = rigid_body.linear_velocity
			original_angular_velocity = rigid_body.angular_velocity
			if DEV_MODE:
				print("[TimeObject] DEV_MODE: Stored original velocities: linear - ", original_velocity, ", angular - ", original_angular_velocity)
	has_logged_initial_velocity = false  # Reset logging flag
	apply_time_manipulation()

# Utility function to find a GravityRigidBody child
func get_child_gravity_rigidbody() -> GravityRigidBody:
	for child in get_children():
		if child is GravityRigidBody:
			if DEV_MODE:
				print("[TimeObject] DEV_MODE: Found GravityRigidBody: ", child.name)
			return child
	if DEV_MODE:
		print("[TimeObject] DEV_MODE: No GravityRigidBody found.")
	return null
