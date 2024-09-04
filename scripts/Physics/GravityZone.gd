extends Area3D

enum GravityType { INDEPENDENT, DEPENDENT }

# Expose properties to the Inspector
@export var gravity_type: GravityType = GravityType.INDEPENDENT
@export var independent_gravity_direction: Vector3 = Vector3.DOWN
@export var use_local_down: bool = false
@export var dependent_gravity_magnitude: float = 9.8
@export var dependent_gravity_points: Array[Node] = [] # Assumes points are of type Node or similar
@export var gravitate_to_closest: bool = true
@export var repel: bool = false
@export var DEV_MODE: bool = false # Development mode toggle for debugging output

var affected_objects = []
var zone_gravity_direction = Vector3.ZERO
var zone_gravity_magnitude = 0.0

func _ready():
	# Connect signals for detecting when objects enter or exit the gravity zone
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))
	
	# Initial debug output for gravity settings
	if DEV_MODE:
		print("[GravityZone] DEV_MODE: Gravity Zone Initialized with the following settings:")
		print("[GravityZone] DEV_MODE: Gravity Type:", gravity_type)
		print("[GravityZone] DEV_MODE: Independent Gravity Direction:", independent_gravity_direction)
		print("[GravityZone] DEV_MODE: Use Local Down:", use_local_down)
		print("[GravityZone] DEV_MODE: Dependent Gravity Magnitude:", dependent_gravity_magnitude)
		print("[GravityZone] DEV_MODE: Dependent Gravity Points:", dependent_gravity_points)
		print("[GravityZone] DEV_MODE: Gravitate to Closest:", gravitate_to_closest)
		print("[GravityZone] DEV_MODE: Repel:", repel)
	
	# Calculate initial gravity settings if independent
	if gravity_type == GravityType.INDEPENDENT:
		_calculate_independent_gravity()

func _calculate_independent_gravity():
	zone_gravity_direction = independent_gravity_direction
	if use_local_down:
		zone_gravity_direction = -transform.basis.y.normalized()
	zone_gravity_magnitude = dependent_gravity_magnitude

	if DEV_MODE:
		print("[GravityZone] DEV_MODE: Initial Independent Gravity Calculated:")
		print("[GravityZone] DEV_MODE: Zone Gravity Direction:", zone_gravity_direction)
		print("[GravityZone] DEV_MODE: Zone Gravity Magnitude:", zone_gravity_magnitude)

func _on_body_entered(body):
	if body is RigidBody3D:
		if DEV_MODE:
			print("[GravityZone] DEV_MODE: Detected object:", body.name)
		if body.has_method("add_gravity"):  # Changed to use add_gravity
			if DEV_MODE:
				print("[GravityZone] DEV_MODE: Object has GravityRigidBody script:", body.name)
			affected_objects.append(body)
			_apply_gravity_to_object(body)  # Immediately calculate and apply gravity

func _on_body_exited(body):
	if body is RigidBody3D and body in affected_objects:
		if DEV_MODE:
			print("[GravityZone] DEV_MODE: Object exited zone:", body.name)
		affected_objects.erase(body)

func _process(_delta): # Prefix delta with an underscore to avoid the warning
	# Update gravity for all objects in the zone
	for object in affected_objects:
		_apply_gravity_to_object(object)

func _apply_gravity_to_object(object: RigidBody3D):
	var direction = Vector3.ZERO
	var magnitude = 0.0
	
	if gravity_type == GravityType.INDEPENDENT:
		# Use pre-calculated zone gravity direction and magnitude
		direction = zone_gravity_direction
		magnitude = zone_gravity_magnitude

		if DEV_MODE:
			print("[GravityZone] DEV_MODE: Applying Independent Gravity to:", object.name)
			print("[GravityZone] DEV_MODE: Using Pre-calculated Direction:", direction)
			print("[GravityZone] DEV_MODE: Magnitude:", magnitude)
			
	elif gravity_type == GravityType.DEPENDENT:
		var closest_point = null
		var min_distance = INF
		for point in dependent_gravity_points:
			var distance = object.global_transform.origin.distance_to(point.global_transform.origin)
			if DEV_MODE:
				print("[GravityZone] DEV_MODE: Distance from", object.name, "to", point.name, "is:", distance)
			if (gravitate_to_closest and distance < min_distance) or (!gravitate_to_closest and distance > min_distance):
				closest_point = point
				min_distance = distance
		if closest_point:
			direction = (closest_point.global_transform.origin - object.global_transform.origin).normalized()
			if repel:
				direction = -direction
			magnitude = dependent_gravity_magnitude
			
			if DEV_MODE:
				print("[GravityZone] DEV_MODE: Applying Dependent Gravity to:", object.name)
				print("[GravityZone] DEV_MODE: Closest Point:", closest_point.name)
				print("[GravityZone] DEV_MODE: Calculated Direction:", direction)
				print("[GravityZone] DEV_MODE: Magnitude:", magnitude)
	
	# Call the add_gravity method on the object to add its gravity
	if direction != Vector3.ZERO:
		if DEV_MODE:
			print("[GravityZone] DEV_MODE: Adding gravity for:", object.name)
			print("[GravityZone] DEV_MODE: Gravity Direction to Add:", direction.normalized())
			print("[GravityZone] DEV_MODE: Gravity Magnitude to Add:", magnitude)
		object.call("add_gravity", direction.normalized(), magnitude)
