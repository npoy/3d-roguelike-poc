@tool
extends Node3D

@export var GroundScene: PackedScene
@export var ObstacleScene: PackedScene
@export var level_name: String = "New level"

var shader_material: ShaderMaterial

@export_range(1, 21) var map_width: int = 3:
	get: return map_width
	set(value):
		map_width = value

@export_range(1, 15) var map_depth: int = 3:
	get: return map_depth
	set(value):
		map_depth = value

@export_range(0, 1, 0.05) var obstacle_density: float = 0.2:
	get: return obstacle_density
	set(value):
		obstacle_density = value

@export_range(1, 5) var obstacle_max_height: float = 5:
	get: return obstacle_max_height
	set(value):
		obstacle_max_height = max(value, obstacle_min_height)

@export_range(1, 5) var obstacle_min_height: float = 1:
	get: return obstacle_min_height
	set(value):
		obstacle_min_height = min(value, obstacle_max_height)

@export var rng_seed: int:
	get: return rng_seed
	set(value):
		rng_seed = value

@export var foreground_color: Color
@export var background_color: Color:
	get: return background_color
	set(value):
		background_color = value
		
@export var generate_level: bool:
	get: return generate_level
	set(value):
		update_map_center()
		generate_map()
		
@export var save: bool:
	get: return save
	set(value): save_level()

var map_coords: Array = []
var obstacle_map: Array = []
var map_center: Coord
var level: Node3D

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
	update_map_center() # TODO: Should this be here?
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
	add_level()
	add_map()
	update_obstacle_material()
	add_obstacles()

func clear_map() -> void:
	for node in get_children():
		if node is CSGBox3D:
			node.queue_free()
		elif node is Node3D:
			remove_csg_boxes_in_node(node)
			node.queue_free()

func remove_csg_boxes_in_node(node: Node3D) -> void:
	for child in node.get_children():
		if child is CSGBox3D:
			child.queue_free()

func save_level() -> void:
	var packed_scene = PackedScene.new()
	"""
		- Moving children to the level and then back to the map
		- ground.tscn has got the default transform and position from the PackedScene
		  instead of the actual position configured at creation.
		  Didn't happen the same for obstacles, why?
	"""
	
	for child in level.get_children():
		child.owner = level
	packed_scene.pack(level)
	var scene_resource_path = "res://Level/LevelGenerator/Levels/%s.tscn" % level_name
	ResourceSaver.save(packed_scene, scene_resource_path)
	for child in level.get_children():
		child.owner = self

func add_level() -> void:
	level = Node3D.new()
	level.name = "Level" # TODO: Why does it not set the name sometimes?
	add_child(level)
	level.owner = self
			
func add_map() -> void:
	var ground: CSGBox3D = GroundScene.instantiate()
	ground.size = Vector3(map_width, 1, map_depth)
	ground.global_transform.origin = Vector3(0, 0, 0)
	level.add_child(ground)
	ground.owner = self

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
	
	var obstacles_qty: int = map_coords.size() * obstacle_density
	var current_obstacle_qty = 0
	
	if obstacles_qty > 0:
		for coord in map_coords.slice(0, obstacles_qty - 1):
			if not map_center.is_equal(coord):
				current_obstacle_qty += 1
				obstacle_map[coord.x][coord.z] = true
				if is_map_fully_accessible(current_obstacle_qty):
					create_obstacle_at(coord)
				else:
					current_obstacle_qty -= 1
					obstacle_map[coord.x][coord.z] = false

func is_map_fully_accessible(current_obstacle_qty):
	# Flood fill
	var checked_coords = []
	for x in range(map_width):
		checked_coords.append([])
		for z in range(map_depth):
			checked_coords[x].append(false)
	
	var coords_to_check = [map_center]
	checked_coords[map_center.x][map_center.z] = true
	var accessible_coord_count = 1
	
	while coords_to_check:
		var current_coord: Coord = coords_to_check.pop_front()
		for x in [-1, 0, 1]:
			for z in [-1, 0, 1]:
				if x == 0 or z == 0:  # non-diagonal neighbor
					var neighbor = Coord.new(current_coord.x + x, current_coord.z + z)
					if is_on_the_map(neighbor):
						if not checked_coords[neighbor.x][neighbor.z]:
							if not obstacle_map[neighbor.x][neighbor.z]:
								checked_coords[neighbor.x][neighbor.z] = true
								coords_to_check.append(neighbor)
								accessible_coord_count += 1

	var target_accessible_coord_count = map_width * map_depth - current_obstacle_qty
	if target_accessible_coord_count == accessible_coord_count:
		return true
	else:
		return false
						
func is_on_the_map(coord: Coord):
	return coord.x >= 0 and coord.x < map_width and coord.z >= 0 and coord.z < map_depth
					
func create_obstacle_at(coord: Coord) -> void:
	var obstacle_position: Vector3 = Vector3(coord.x, 0.5, coord.z) # TODO: Pick y value from ground or obstacle
	obstacle_position -= Vector3(map_width/2, 0, map_depth/2)
	var obstacle: CSGBox3D = ObstacleScene.instantiate()

	obstacle.height = get_obstacle_height()
	obstacle.global_transform.origin = obstacle_position + Vector3(0, obstacle.get_size().y/2, 0)
	level.add_child(obstacle)
	obstacle.owner = self

func get_obstacle_height() -> float:
	return randf_range(obstacle_min_height, obstacle_max_height)

func update_map_center():
	map_center = Coord.new(map_width/2, map_depth/2)
