@tool
extends Node3D

@export var GroundScene: PackedScene
@export var ObstacleScene: PackedScene

@export_range(1, 21) var map_width: int = 11:
	get: return map_width
	set(value):
		map_width = value
		generate_map()

@export_range(1, 15) var map_depth: int = 11:
	get: return map_depth
	set(value):
		map_depth = value
		generate_map()

@export_range(0, 1, 0.05) var obstacle_density: float = 0.2:
	get: return obstacle_density
	set(value):
		obstacle_density = value
		generate_map()

@export_range(1, 5) var obstacle_max_height: float = 5:
	get: return obstacle_max_height
	set(value):
		obstacle_max_height = max(value, obstacle_min_height)
		generate_map()

@export_range(1, 5) var obstacle_min_height: float = 1:
	get: return obstacle_min_height
	set(value):
		obstacle_min_height = min(value, obstacle_max_height)
		generate_map()

@export var rng_seed: int:
	get: return rng_seed
	set(value):
		rng_seed = value
		generate_map()

var map_coords: Array = []

class Coord:
	var x: int
	var z: int
	
	func _init(x: int, z: int):
		self.x = x
		self.z = z

	func _to_string():
		# (x, z)
		return "{" + str(x) + ", " + str(z) + "}"

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_map() # TODO: Create make_odd method? check later

func fill_map_coords() -> void:
	map_coords = []
	for x in range(map_width):
		for z in range(map_depth):
			map_coords.append(Coord.new(x, z))

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
	fill_map_coords()
	seed(rng_seed)
	map_coords.shuffle()
	var obstacle_qty: int = map_coords.size() * obstacle_density
	if (obstacle_qty > 0):
		for coord in map_coords.slice(0, obstacle_qty):
			add_obstacle_at(coord)
	
func add_obstacle_at(coord: Coord):
	var obstacle_position: Vector3 = Vector3(coord.x, 1, coord.z)
	obstacle_position -= Vector3(map_width/2, 0, map_depth/2)
	var obstacle: CSGBox3D = ObstacleScene.instantiate()
	obstacle.global_transform.origin = obstacle_position
	add_child(obstacle)

