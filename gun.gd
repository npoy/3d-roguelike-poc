extends Node3D

@export var bullet: PackedScene
@export var muzzle_speed = 30
@export var time_between_shots = 100 # In milliseconds
@onready var timer: Timer = $Timer

var can_shoot: bool = true

func _process(delta):
	shoot()
	
func shoot():
	if can_shoot == true:
		var bullet = bullet.instantiate()
		bullet.global_transform = $Muzzle.global_transform # TODO: Check if using global is really needed in this scenario
		bullet.speed = muzzle_speed
		# TODO: Refactor using the corresponding pattern, why would we get the root like this?
		var root_scene = get_tree().get_root().get_children()[0]
		root_scene.add_child(bullet)
		can_shoot = false
		timer.start()

func _on_timer_timeout():
	can_shoot = true
