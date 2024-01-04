extends Area2D
@onready var nextLevel = preload("res://levels/level3/level_3.tscn")

func _on_body_entered(body):
	get_tree().change_scene_to_packed(nextLevel)
