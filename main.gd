extends Node3D

"""
	TODO: Review Directional Light pixelated shadows
"""
var ray_lenght: int = 2000
@onready var player: CharacterBody3D = $Player # TODO: Fix relative path

func _physics_process(delta):
	var camera = $Camera3D
	var mouse_position: Vector2 = get_viewport().get_mouse_position()
	var ray_origin: Vector3 = $Camera3D.project_ray_origin(mouse_position)
	var ray_target: Vector3 = ray_origin + $Camera3D.project_ray_normal(mouse_position) * ray_lenght
	
	var ray_query = PhysicsRayQueryParameters3D.create(ray_origin, ray_target)
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var intersection: Dictionary = space_state.intersect_ray(ray_query)
	
	if not intersection.is_empty():
		if (player != null):
			var pos = Vector3(intersection.position.x, player.position.y, intersection.position.z)
			player.look_at(pos, Vector3.UP)
	
