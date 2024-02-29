extends Node2D

func _ready():
	get_node("/root/GameVariables").dashUnlocked = true
	get_parent().get_node("Player").dashUnlocked = true
