extends RigidBody3D

@export var speed: int = 30
@export var damage: int = 1
@onready var timer: Timer = $Timer
# Preferred to use a Timer node. This is more for one shot timers 
#@onready var timer: SceneTreeTimer = get_tree().create_timer(2)

func _physics_process(delta):
	var forward_direction: Vector3 = global_transform.basis.z.normalized()
	"""
		Basically doing distance = speed * time
		e.g. translation = Vector3(0, 0, -1) * 70 * 0.5
		With speed (70) being the magnitude of the velocity vector(70/1 - vector quantity)
	"""
	# Using translate() is the same since the origin is the parent anyway
	#global_translate(forward_direction * speed * delta)
	var collision: KinematicCollision3D = move_and_collide(forward_direction * speed * delta)
	""" TODO: Fix shooting/collision when gun is inside the blocks or enemies """
	if collision:
		var body = collision.get_collider()
		if body.has_node("Stats"):
			queue_free()
			var stats: Stats = body.find_child("Stats") as Stats
			stats.take_hit(damage)
		if body.is_in_group("World"):
			queue_free()
	
func _on_timer_timeout():
	queue_free()
