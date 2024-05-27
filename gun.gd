extends Node3D

@export var bullet: PackedScene
@export var muzzle_speed = 30
@export var time_between_shots = 100 # In milliseconds

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	shoot()
	
func shoot():
	var bullet = bullet.instantiate()
	bullet.global_transform = $Muzzle.global_transform
	#bullet.speed = muzzle_speed
	# TODO: Refactor using the corresponding patter, why would we get the root like this?
	var root_scene = get_tree().get_root().get_children()[0]
	root_scene.add_child(bullet)
