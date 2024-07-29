extends CharacterBody3D

"""
	TODO: Many methods and variables created with no sense
	but they help to understand the functionality
"""

var default_material: Material = load("res://Enemy/enemy_default_material.tres")
var attack_material: Material = load("res://Enemy/enemy_attack_material.tres")
var resting_material: Material = load("res://Enemy/enemy_resting_material.tres")

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var player: CharacterBody3D = $"../Player" # TODO: Fix relative path
@onready var attack_timer: Timer = $AttackTimer

@export var attack_speed: int = 10
@export var movement_speed: float = 2.0
@export var time_between_hits: int = 2

var movement_target_position: Vector3 = Vector3(-3.0,0.0,2.0)
var path: Array = []

var attack_target: Vector3
var return_target: Vector3

"""
	TODO: Improve FSM taking it to a next level like in slippy soap
"""
enum state {
	SEEKING,
	ATTACKING,
	RETURNING,
	RESTING,
}

var current_state: state = state.SEEKING

func _ready():
	$MeshInstance3D.set_surface_override_material(0, default_material)
	
	# These values need to be adjusted for the actor's speed
	# and the navigation layout. 
	navigation_agent.path_desired_distance = 0.5
	navigation_agent.target_desired_distance = 0.5
	attack_timer.wait_time = time_between_hits

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame
	# Now that the navigation map is no longer empty, set the movement target.
	if is_instance_valid(player):
		set_movement_target(player.global_transform.origin)

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)

func _physics_process(delta):
	if not is_instance_valid(player):
		return

	match current_state:
		state.SEEKING:
			""" TODO: Set a random path for the enemy if no players """
			actor_setup()
			if navigation_agent.is_navigation_finished():
				return

			var current_agent_position: Vector3 = global_position
			var next_path_position: Vector3 = navigation_agent.get_next_path_position()
			
			"""
				direction_to is equivalent to using => (b - a).normalized() - Might be not normalized and represent a vector with a real lenght instead of unit
				Vector subtraction axis z and x
				This Vector3 does not seem to have a real direction
				Vector3 is in standard position from origin
				and the direction it's determined by the sign probably
				Note: Refresh the direction in standard position and Godot global_position
			"""
			velocity = current_agent_position.direction_to(next_path_position) * movement_speed
			move_and_slide()
			# Same as a on body entered signal. Alternative to validate entering and leaving the zone
			if $AttackRadius.overlaps_body(player):
				attack()
		state.ATTACKING:
			move_and_attack()
		state.RETURNING:
			move_and_attack()
		state.RESTING:
			velocity = Vector3.ZERO
			move_and_slide()

func move_and_attack():
	var distance: float = global_position.distance_to(attack_target)
	velocity = global_position.direction_to(attack_target) * attack_speed
	move_and_slide()
	if (distance < 1):
		match current_state:
			state.ATTACKING:
				var player_stats: Stats = player.get_node("Stats") as Stats
				player_stats.take_hit(1)
				
				current_state = state.RETURNING
				attack_target = return_target
			state.RETURNING:
				attack_timer.start()
				current_state = state.RESTING
				$MeshInstance3D.set_surface_override_material(0, resting_material)
				toggle_enemies_collision(true)

func _on_stats_died():
	queue_free()

#func _on_AttackRadius_body_entered(body):
func attack():
	#if body == player:
	attack_target = player.global_position
	return_target = global_position
	current_state = state.ATTACKING
	$MeshInstance3D.set_surface_override_material(0, attack_material)
	toggle_enemies_collision(false)

"""
	TODO: Validate since 2nd attack does not work if player does not go out of the zone before
	is this signal useful?
"""

func _on_attack_timer_timeout():
	current_state = state.SEEKING
	$MeshInstance3D.set_surface_override_material(0, default_material)

func toggle_enemies_collision(should_collide: bool):
	set_collision_mask_value(3, should_collide)
	set_collision_layer_value(3, should_collide)
