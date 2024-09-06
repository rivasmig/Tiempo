extends RigidBody3D

class_name GravityRigidBody

# Variables to store accumulated forces and time multiplier
var accumulated_forces: Vector3 = Vector3.ZERO
var accumulated_torques: Vector3 = Vector3.ZERO
var accumulated_impulses: Vector3 = Vector3.ZERO
var accumulated_gravity_vector: Vector3 = Vector3.ZERO
var accumulated_gravity_magnitude: float = 0.0
@export var DEV_MODE: bool = false  # Development mode toggle for debugging output
var time_speed: float = 1.0  # Time speed multiplier
var is_time_reversed: bool = false  # Boolean to indicate time direction

# Variable to store the previous time speed
var previous_time_speed: float = 1.0  # Initialize to 1 (or any non-zero default)

func _ready():
	# Enable physics processing
	set_physics_process(true)
	if DEV_MODE:
		print("[GravityRigidBody] DEV_MODE: Initialized for:", self.name)

func _physics_process(_delta):
	# Apply accumulated forces, impulses, and torques based on the adjusted time
	_apply_forces_and_impulses()
	_reset_forces_and_impulses()

# Function to adjust a vector based on time speed, direction, and type
func adjusted_vector(vector: Vector3, vector_type: String) -> Vector3:
	# Determine if we should reverse the vector based on the type and time direction
	if vector_type in ["impulse", "force", "torque"]:
		# For velocities, always reverse if time is reversed
		vector *= -1 if is_time_reversed else 1

	elif vector_type == "velocity":
		# For impulses, forces, or torques, reverse only when the time speed changes sign
		if (time_speed < 0 and previous_time_speed >= 0) or (time_speed >= 0 and previous_time_speed < 0):
			vector *= -1
			if DEV_MODE:
				print("[GravityRigidBody] DEV_MODE: Time direction changed. %s reversed to: %s" % [vector_type.capitalize(), vector])

	# Correctly scale the vector by the new time speed
	var scaling_factor = abs(time_speed) / abs(previous_time_speed)
	vector *= scaling_factor

	# Update the previous time speed for the next frame
	previous_time_speed = time_speed

	return vector

# Apply accumulated forces, impulses, and torques dynamically considering the time speed multiplier
func _apply_forces_and_impulses():
	# Apply forces
	if accumulated_forces != Vector3.ZERO:
		var adjusted_force = adjusted_vector(accumulated_forces, "force")
		apply_central_force(adjusted_force)
		if DEV_MODE:
			var force_direction = "Reversing" if is_time_reversed else "Applying"
			print("[GravityRigidBody] DEV_MODE: %s force: %s for: %s" % [force_direction, adjusted_force, self.name])
	
	# Apply impulses
	if accumulated_impulses != Vector3.ZERO:
		var adjusted_impulse = adjusted_vector(accumulated_impulses, "impulse")
		apply_central_impulse(adjusted_impulse)
		if DEV_MODE:
			var impulse_direction = "Reversing" if is_time_reversed else "Applying"
			print("[GravityRigidBody] DEV_MODE: %s impulse: %s for: %s" % [impulse_direction, adjusted_impulse, self.name])

	# Apply torques
	if accumulated_torques != Vector3.ZERO:
		var adjusted_torque = adjusted_vector(accumulated_torques, "torque")
		apply_torque(adjusted_torque)
		if DEV_MODE:
			var torque_direction = "Reversing" if is_time_reversed else "Applying"
			print("[GravityRigidBody] DEV_MODE: %s torque: %s for: %s" % [torque_direction, adjusted_torque, self.name])

# Add force to the accumulated forces to be applied next physics frame
func add_force(force: Vector3):
	accumulated_forces += force
	if DEV_MODE:
		print("[GravityRigidBody] DEV_MODE: Adding force:", force, "for:", self.name)
		print("[GravityRigidBody] DEV_MODE: New accumulated forces:", accumulated_forces)

# Add impulse to the accumulated impulses to be applied next physics frame
func add_impulse(impulse: Vector3):
	accumulated_impulses += impulse
	if DEV_MODE:
		print("[GravityRigidBody] DEV_MODE: Adding impulse:", impulse, "for:", self.name)
		print("[GravityRigidBody] DEV_MODE: New accumulated impulses:", accumulated_impulses)

# Add torque to the accumulated torques to be applied next physics frame
func add_torque(torque: Vector3):
	accumulated_torques += torque
	if DEV_MODE:
		print("[GravityRigidBody] DEV_MODE: Adding torque:", torque, "for:", self.name)
		print("[GravityRigidBody] DEV_MODE: New accumulated torques:", accumulated_torques)

# Set the time speed multiplier and time direction
func set_time_speed(new_time_speed: float):
	time_speed = abs(new_time_speed)
	is_time_reversed = new_time_speed < 0  # Determine if time is reversed

	# Adjust linear and angular velocities according to the new time speed and direction
	linear_velocity = adjusted_vector(linear_velocity, "velocity")
	angular_velocity = adjusted_vector(angular_velocity, "velocity")
	if DEV_MODE:
		print("[GravityRigidBody] DEV_MODE: Time is %s. Adjusted velocities. Linear: %s, Angular: %s" % 
			  ["reversed" if is_time_reversed else "forward", linear_velocity, angular_velocity])

# Reset accumulated forces, impulses, and torques at the end of each frame
func _reset_forces_and_impulses():
	accumulated_forces = Vector3.ZERO
	accumulated_impulses = Vector3.ZERO
	accumulated_torques = Vector3.ZERO
	accumulated_gravity_vector = Vector3.ZERO
	accumulated_gravity_magnitude = 0.0
	if DEV_MODE:
		print("[GravityRigidBody] DEV_MODE: Forces, impulses, and torques reset for:", self.name)

# Add gravity from a GravityZone dynamically
func add_gravity(direction: Vector3, magnitude: float):
	accumulated_gravity_vector += direction.normalized() * magnitude
	accumulated_gravity_magnitude += magnitude

	# Convert gravity to a force and add it to accumulated forces
	var gravity_force = accumulated_gravity_vector.normalized() * accumulated_gravity_magnitude * mass
	add_force(gravity_force)

	if DEV_MODE:
		print("[GravityRigidBody] DEV_MODE: Added gravity for:", self.name)
		print("[GravityRigidBody] DEV_MODE: Gravity direction:", direction, "Magnitude:", magnitude)
		print("[GravityRigidBody] DEV_MODE: New accumulated gravity vector:", accumulated_gravity_vector)
		print("[GravityRigidBody] DEV_MODE: New accumulated gravity magnitude:", accumulated_gravity_magnitude)
