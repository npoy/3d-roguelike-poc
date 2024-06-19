extends Node

@export var enemy: PackedScene
@onready var timer: Timer = $Timer
#@export var enemies_qty: int = 3
#@export var spawn_time: int = 2
#var spawned_enemies: int = 0

@export var waves: Array[Wave] = []
var current_wave: Wave

# Called when the node enters the scene tree for the first time.
func _ready():
	waves = $Waves.get_childrens()
	#timer.wait_time = spawn_time
	timer.start()

func _on_timer_timeout():
	#if (spawned_enemies == enemies_qty):
		#spawned_enemies = 0

	#if (enemies_qty > spawned_enemies):
		var newEnemy = enemy.instantiate()
		get_parent().add_child(newEnemy)
		#spawned_enemies += 1
