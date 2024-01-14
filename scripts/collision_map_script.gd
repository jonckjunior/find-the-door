extends Node2D


func _ready():
	for child in get_children():
		if child.is_class("StaticBody2D"):
			child.add_to_group("map")
