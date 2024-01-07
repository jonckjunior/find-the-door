extends PointLight2D

@export var target: CharacterBody2D

func _process(delta):
	if target != null:
		global_position = lerp(global_position, target.global_position, delta * 4)
