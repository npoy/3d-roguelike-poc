extends Node3D

"""
	TODO: Review Directional Light pixelated shadows
"""
var ray_lenght: int = 2000
@onready var player: CharacterBody3D = $Player # TODO: Fix relative path
@onready var player_hand: Marker3D = $Player/Body/Hand

func _physics_process(delta):
	var camera = $Camera3D
	var mouse_position: Vector2 = get_viewport().get_mouse_position()
	var ray_origin: Vector3 = $Camera3D.project_ray_origin(mouse_position)
	var ray_target: Vector3 = ray_origin + $Camera3D.project_ray_normal(mouse_position) * ray_lenght
	
	var ray_query = PhysicsRayQueryParameters3D.create(ray_origin, ray_target, 8) #TODO: Use constants for layers
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var intersection: Dictionary = space_state.intersect_ray(ray_query)
	
	if is_instance_valid(player) and not intersection.is_empty():
		var pointer_pos = Vector3(intersection.position.x, player.position.y, intersection.position.z)
		var hand_pos = Vector3(intersection.position.x, player_hand.global_position.y, intersection.position.z)
		player.look_at(pointer_pos)
		"""
			Validate Vector and Matrix rotations. 3D rotation, rotation axis, Why does it need Vector3.UP?
			- Orthogonal transformations: https://chatgpt.com/c/f659ca38-9a12-415b-b811-2b43e19af1a8
		"""
		var distance_to_pointer: Vector3 = player_hand.global_position - pointer_pos
		
		# TODO: * Not use arbitrary values, check for mesh sizes?
		#var gun = $Player/GunController.equipped_weapon
		#print_debug(gun)
		#var mesh = gun.get_node("MeshInstance3D")
		#var mesh2 = mesh.get_mesh()
		#print_debug(mesh2)
		#print_debug(mesh2.get_aabb())
		
		if distance_to_pointer.length() > 3: # *
			player_hand.look_at(hand_pos)
	
