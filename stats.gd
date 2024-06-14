extends Node

""" TODO: Check if I need to actually add a class_name in order to get_child() """
""" TODO: This should be a .tres file and should have methods """
class_name Stats

signal died

@export var max_hp: int = 10
var current_hp = max_hp

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func take_hit(damage: int):
	current_hp -= damage
	if current_hp <= 0:
		die()

""" Does not make sense to have die here """
func die():
	emit_signal("died")
