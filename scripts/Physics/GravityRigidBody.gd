extends RigidBody3D

class_name GravityRigidBody

# Variables to store cumulative gravity direction and magnitude
var accumulated_gravity_vector: Vector3 = Vector3.ZERO
var accumulated_gravity_magnitude: float = 0.0
@export var DEV_MODE: bool = false # Development mode toggle for debugging output

func _ready():
	# Enable processing for physics calculations
	set_physics_process(true)
	if DEV_MODE:
		print("[GravityRigidBody] DEV_MODE: GravityRigidBody Initialized for:", self.name)

func _physics_process(_delta):
	# Apply gravity during the physics step
	_apply_gravity()
	_reset_gravity() # Reset gravity after applying it to allow new additions each frame

# Apply the accumulated gravity force to the rigid body
func _apply_gravity():
	if accumulated_gravity_vector != Vector3.ZERO:
		var gravity_force = accumulated_gravity_vector.normalized() * accumulated_gravity_magnitude * mass
		if DEV_MODE:
			print("[GravityRigidBody] DEV_MODE: Applying Gravity to:", self.name)
			print("[GravityRigidBody] DEV_MODE: Gravity Force:", gravity_force)
		apply_central_force(gravity_force)

# Add gravity from a GravityZone
func add_gravity(direction: Vector3, magnitude: float):
	accumulated_gravity_vector += direction.normalized() * magnitude
	accumulated_gravity_magnitude += magnitude
	if DEV_MODE:
		print("[GravityRigidBody] DEV_MODE: Adding Gravity for:", self.name)
		print("[GravityRigidBody] DEV_MODE: Added Gravity Direction:", direction)
		print("[GravityRigidBody] DEV_MODE: Added Gravity Magnitude:", magnitude)
		print("[GravityRigidBody] DEV_MODE: New Cumulative Gravity Vector:", accumulated_gravity_vector)
		print("[GravityRigidBody] DEV_MODE: New Cumulative Gravity Magnitude:", accumulated_gravity_magnitude)

# Reset the accumulated gravity after each frame
func _reset_gravity():
	accumulated_gravity_vector = Vector3.ZERO
	accumulated_gravity_magnitude = 0.0
	if DEV_MODE:
		print("[GravityRigidBody] DEV_MODE: Reset Gravity for:", self.name)
