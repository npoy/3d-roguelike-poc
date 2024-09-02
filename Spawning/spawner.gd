extends Node

@export var enemy: PackedScene
@export var waves: Array[Wave]
@onready var timer: Timer = $Timer
var current_wave: Wave
var current_wave_index: int = 0
var spawned_enemies: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	start_wave()
	#pass
	
func start_wave() -> void:
	spawned_enemies = 0
	current_wave_index = randi_range(0, waves.size() - 1)
	current_wave = waves[current_wave_index]
	timer.wait_time = current_wave.spawn_time
	timer.start()

func _on_timer_timeout():
	if (spawned_enemies == current_wave.enemies_qty):
		start_wave()

	if (current_wave.enemies_qty > spawned_enemies):
		var newEnemy = enemy.instantiate()
		get_parent().add_child(newEnemy)
		spawned_enemies += 1
