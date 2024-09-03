@tool
extends Node3D

@export var GroundScene: PackedScene
@export var ObstacleScene: PackedScene

@export_range(1, 21) var map_width: int = 11:
	get:
		return map_width
	set(value):
		map_width = value
		generate_map()

@export_range(1, 15) var map_depth: int = 11:
	get:
		return map_depth
	set(value):
		map_depth = value
		generate_map()

@export_range(0, 1, 0.05) var obstacle_ratio: float = 0.2:
	get:
		return obstacle_ratio
	set(value):
		obstacle_ratio = value
		generate_map()

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_map() # TODO: Create make_odd method? check later
	
func generate_map() -> void:
	clear_map()
	add_map()
	add_obstacles()

func clear_map():
	for node in get_children():
		if node is CSGBox3D:
			node.queue_free()
			
func add_map():
	var ground: CSGBox3D = GroundScene.instantiate()
	ground.size = Vector3(map_width, 1, map_depth)
	ground.global_transform.origin = Vector3(0, 0, 0)
	add_child(ground)

func add_obstacles():
	for x in range(map_width):
		for z in range(map_depth):
			if(randf() < obstacle_ratio):
				var obstacle_position: Vector3 = Vector3(x, 1, z)
				obstacle_position -= Vector3(map_width/2, 0, map_depth/2)
				var obstacle: CSGBox3D = ObstacleScene.instantiate()
				obstacle.global_transform.origin = obstacle_position
				add_child(obstacle)
				
