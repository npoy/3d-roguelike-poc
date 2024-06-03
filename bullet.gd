extends Node3D

@export var speed = 30
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
	global_translate(forward_direction * speed * delta)
	
func _on_timer_timeout():
	queue_free()

func _on_area_3d_body_entered(body):
	print_debug("hit: ", body)
	queue_free()
