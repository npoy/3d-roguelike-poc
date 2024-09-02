@tool
extends Node3D

@export var GroundScene: PackedScene
@export_range(1, 20) var map_width: int = 11:
	get:
		return map_width
	set(value):
		map_width = value
		generate_map()

@export_range(1, 20) var map_depth: int = 11:
	get:
		return map_depth
	set(value):
		map_depth = value
		generate_map()

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_map()
	
func generate_map() -> void:
	for node in get_children():
		node.queue_free()
	var ground: CSGBox3D = GroundScene.instantiate()
	ground.size = Vector3(map_width, 1, map_depth)
	add_child(ground)
