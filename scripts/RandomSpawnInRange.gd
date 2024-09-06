extends Node

@export var preset_scene: PackedScene
@export var spawn_corner1: Node3D
@export var spawn_corner2: Node3D

func _ready():
	# Ensure the input is enabled for this node
	set_process_input(true)

func _input(event):
	# Check if the player is pressing the right-click action
	if Input.is_action_pressed("click"):
		spawn_node_at_random_location()

func spawn_node_at_random_location():
	# Ensure the preset scene and spawn corners are assigned
	if not preset_scene:
		print("Preset scene is not assigned.")
		return
	if not spawn_corner1 or not spawn_corner2:
		print("Spawn corner nodes are not assigned.")
		return

	# Create an instance of the preset node
	var new_node = preset_scene.instantiate() as Node3D
	if not new_node:
		print("The instantiated node is not a Node3D.")
		return

	# Add the new node to the current scene first
	add_child(new_node)

	# Now, get the global positions of the two corner nodes
	var pos1 = spawn_corner1.global_position
	var pos2 = spawn_corner2.global_position

	# Calculate the random position within the box defined by the two corners
	var random_position = Vector3(
		randf_range(min(pos1.x, pos2.x), max(pos1.x, pos2.x)),
		randf_range(min(pos1.y, pos2.y), max(pos1.y, pos2.y)),
		randf_range(min(pos1.z, pos2.z), max(pos1.z, pos2.z))
	)

	# Set the global position of the new node after adding it to the scene
	new_node.global_position = random_position

	print("Spawned a node at position:", random_position)
