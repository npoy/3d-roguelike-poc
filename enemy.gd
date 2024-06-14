extends CharacterBody3D

"""
	TODO: Many methods and variables created with no sense
	but they help to understand the functionality
"""

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var player: CharacterBody3D = $"../Player" # TODO: Fix relative path
var movement_speed: float = 2.0
var movement_target_position: Vector3 = Vector3(-3.0,0.0,2.0)
var path: Array = []

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 0.5
	navigation_agent.target_desired_distance = 0.5

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(player.global_transform.origin)

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)

func _physics_process(delta):
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

func _on_stats_died():
	queue_free()
