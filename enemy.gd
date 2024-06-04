extends CharacterBody3D

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var player: CharacterBody3D = $"../Player" # TODO: Fix relative path

var path: Array = []

func _ready():
	pass
