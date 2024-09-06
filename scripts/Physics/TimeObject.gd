extends Node3D

# Time manipulation variable
var time_speed: float = 1.0

# Enable/Disable development mode for debugging
@export var DEV_MODE: bool = false

# Reference to the custom GravityRigidBody
@onready var target_physics_body: GravityRigidBody = get_child_gravity_rigidbody()

func _ready():
	# Check if a valid GravityRigidBody is attached
	if not target_physics_body:
		push_warning("TimeObject requires a GravityRigidBody as a child node!")
		if DEV_MODE:
			print("[TimeObject] DEV_MODE: No GravityRigidBody found as a child of", self.name)
	else:
		if DEV_MODE:
			print("[TimeObject] DEV_MODE: Found GravityRigidBody child:", target_physics_body.name)

	# Reference the TimeManager singleton
	if TimeManager:
		TimeManager.connect("time_speed_changed", Callable(self, "_on_time_speed_changed"))
		if DEV_MODE:
			print("[TimeObject] DEV_MODE: Connected to TimeManager's signal.")
	else:
		if DEV_MODE:
			print("[TimeObject] DEV_MODE: TimeManager singleton not found!")

func _physics_process(_delta):
	# Continuously apply time manipulation to the physics body
	if target_physics_body:
		target_physics_body.set_time_speed(time_speed)

# Handle global time speed changes from the singleton
func _on_time_speed_changed(new_speed: float):
	time_speed = new_speed
	if target_physics_body:
		target_physics_body.set_time_speed(time_speed)
	if DEV_MODE:
		print("[TimeObject] DEV_MODE: Time speed changed to:", time_speed)

# Utility function to find a GravityRigidBody child
func get_child_gravity_rigidbody() -> GravityRigidBody:
	for child in get_children():
		if child is GravityRigidBody:
			if DEV_MODE:
				print("[TimeObject] DEV_MODE: Found GravityRigidBody:", child.name)
			return child
	if DEV_MODE:
		print("[TimeObject] DEV_MODE: No GravityRigidBody found.")
	return null
