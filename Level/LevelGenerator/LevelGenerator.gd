@tool
extends Node3D

@export var GroundScene: PackedScene
@export var ObstacleScene: PackedScene

var shader_material: ShaderMaterial

@export_range(1, 21) var map_width: int = 11:
	get: return map_width
	set(value):
		map_width = value
		update_map_center()
		generate_map()

@export_range(1, 15) var map_depth: int = 11:
	get: return map_depth
	set(value):
		map_depth = value
		update_map_center()
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
		update_map_center()
		generate_map()

@export var foreground_color: Color
@export var background_color: Color:
	get: return background_color
	set(value):
		background_color = value
		generate_map()

var map_coords: Array = []
var obstacle_map: Array = []
var map_center: Coord

class Coord:
	var x: int
	var z: int
	
	func _init(x: int, z: int):
		self.x = x
		self.z = z

	func _to_string():
		# (x, z)
		return "{" + str(x) + ", " + str(z) + "}"
	
	func is_equal(coord: Coord):
		return coord.x == self.x and coord.z == self.z

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_map() # TODO: Create make_odd method? check later

func fill_map_coords() -> void:
	map_coords = []
	for x in range(map_width):
		for z in range(map_depth):
			map_coords.append(Coord.new(x, z))

func fill_obstacle_map() -> void:
	obstacle_map = []
	for x in range(map_width):
		obstacle_map.append([])
		for z in range(map_depth):
			obstacle_map[x].append(false)

func generate_map() -> void:
	clear_map()
	add_map()
	update_obstacle_material()
	add_obstacles()

func clear_map() -> void:
	for node in get_children():
		if node is CSGBox3D:
			node.queue_free()
			
func add_map() -> void:
	var ground: CSGBox3D = GroundScene.instantiate()
	ground.size = Vector3(map_width, 1, map_depth)
	ground.global_transform.origin = Vector3(0, 0, 0)
	add_child(ground)

func update_obstacle_material() -> void:
	var temp_obstacle: CSGBox3D = ObstacleScene.instantiate()
	shader_material = temp_obstacle.material as ShaderMaterial
	shader_material.set_shader_parameter("ForegroundColor", foreground_color)
	shader_material.set_shader_parameter("BackgroundColor", background_color)
	shader_material.set_shader_parameter("LevelDepth", map_depth)

func add_obstacles() -> void:
	fill_map_coords()
	fill_obstacle_map()
	seed(rng_seed)
	map_coords.shuffle()
	
	var obstacle_qty: int = map_coords.size() * obstacle_density
	var current_obstacle_qty: int = 0
	
	if (obstacle_qty > 0):
		for coord in map_coords.slice(0, obstacle_qty):
			if not map_center.is_equal(coord):
				current_obstacle_qty += 1
				obstacle_map[coord.x][coord.z] = true # TODO: Check if shouldn't be this flood fill logic all in one specific method?
				if is_map_fully_accesible(current_obstacle_qty):
					create_obstacle_at(coord)
				else:
					current_obstacle_qty -= 1
					obstacle_map[coord.x][coord.z] = false
					
func create_obstacle_at(coord: Coord) -> void:
	var obstacle_position: Vector3 = Vector3(coord.x, 0.5, coord.z) # TODO: Pick y value from ground or obstacle
	obstacle_position -= Vector3(map_width/2, 0, map_depth/2)
	var obstacle: CSGBox3D = ObstacleScene.instantiate()
	
	#var material := StandardMaterial3D.new()
	#material.albedo_color = get_color_at_depth(coord.z)
	#obstacle.material = material
	
	obstacle.height = get_obstacle_height()
	obstacle.global_transform.origin = obstacle_position + Vector3(0, obstacle.get_size().y/2, 0)
	add_child(obstacle)

func get_obstacle_height() -> float:
	return randf_range(obstacle_min_height, obstacle_max_height)

#func get_color_at_depth(z: int):
	#return background_color.lerp(foreground_color, float(z)/map_depth)

func update_map_center():
	map_center = Coord.new(map_width/2, map_depth/2)
