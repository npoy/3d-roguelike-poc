extends Node3D

@export var speed = 70

func _physics_process(delta):
	"""
		Basically doing distance = speed * time
		e.g. translation = Vector3(0, 0, -1) * 70 * 0.5
		With speed (70) being the magnitude of the velocity vector(70/1 - vector quantity)
	"""
	global_translate(Vector3.FORWARD * speed * delta)
