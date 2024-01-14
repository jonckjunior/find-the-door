extends Control


var first_scene = load("res://levels/core_world/level_0/level_0.tscn")


func _process(delta):
	get_tree().change_scene_to_packed(first_scene)
