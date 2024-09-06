extends Camera3D

# Sensitivity and smoothing parameters for mouse look
@export var mouse_sensitivity: float = 0.3
@export var smoothing: float = 0.1

# Speed for WSAD movement
@export var move_speed: float = 5.0

# State variables for smooth mouse look
var mouse_delta: Vector2 = Vector2.ZERO
var smooth_mouse_delta: Vector2 = Vector2.ZERO
var velocity: Vector3 = Vector3.ZERO

# Function for handling input
func _input(event):
	if event is InputEventMouseMotion:
		mouse_delta = event.relative * mouse_sensitivity

# Function for updating camera rotation and movement
func _process(delta):
	# Mouse look (smooth rotation)
	smooth_mouse_delta = smooth_mouse_delta.lerp(mouse_delta, smoothing)
	rotate_object_local(Vector3(1, 0, 0), deg_to_rad(-smooth_mouse_delta.y))
	rotate_y(deg_to_rad(-smooth_mouse_delta.x))
	mouse_delta = Vector2.ZERO
	
	# Limit vertical rotation to prevent flipping
	rotation_degrees.x = clamp(rotation_degrees.x, -90, 90)

	# WSAD controls for movement
	velocity = Vector3.ZERO
	if Input.is_action_pressed("ui_up"):
		velocity -= Vector3(0, 0, 1) # Forward
	if Input.is_action_pressed("ui_down"):
		velocity += Vector3(0, 0, 1) # Backward
	if Input.is_action_pressed("ui_left"):
		velocity -= Vector3(1, 0, 0) # Left
	if Input.is_action_pressed("ui_right"):
		velocity += Vector3(1, 0, 0) # Right
	
	# Normalize velocity to prevent faster diagonal movement and apply speed
	velocity = velocity.normalized() * move_speed

	# Update camera's position using local translation
	translate_object_local(velocity * delta)

# Optional: grab mouse focus when the script starts
func _ready():
	# Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass
