extends Node

@export var starting_weapon: PackedScene

var hand: Marker3D
var equipped_weapon: Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	hand = get_parent().find_child("Hand")
	
	if starting_weapon:
		equip_weapon(starting_weapon)

func equip_weapon(weapon):
	if equipped_weapon:
		equipped_weapon.queue_free()
	else:
		equipped_weapon = weapon.instantiate()
		hand.add_child(equipped_weapon)

func shoot():
	if equipped_weapon:
		equipped_weapon.shoot()
