extends Area2D
@onready var nextLevel = preload("res://levels/level1/level_1.tscn")

func _on_body_entered(body):
	get_tree().change_scene_to_packed(nextLevel)
