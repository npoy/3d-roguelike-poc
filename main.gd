extends Node3D

var ray_lenght: int = 2000

func _physics_process(delta):
	var camera = $Camera3D
	var mouse_position: Vector2 = get_viewport().get_mouse_position()
	var ray_origin: Vector3 = $Camera3D.project_ray_origin(mouse_position)
	var ray_target: Vector3 = ray_origin + $Camera3D.project_ray_normal(mouse_position) * ray_lenght
	#print_debug("Mouse position: ", mouse_position)
	#print_debug("ray_origin: ", ray_origin)
	#print_debug("ray_target: ", ray_target)
	
	var ray_query = PhysicsRayQueryParameters3D.create(ray_origin, ray_target)
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var intersection: Dictionary = space_state.intersect_ray(ray_query)
	
	if not intersection.is_empty():
		var pos = Vector3(intersection.position.x, $Player.position.y, intersection.position.z)
		$Player.look_at(pos, Vector3.UP)
	
