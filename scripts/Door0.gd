extends Area2D
@onready var nextLevel = load("res://levels/level1/level_1.tscn")

func _on_body_entered(body):
	get_tree().change_scene_to_packed(nextLevel)
