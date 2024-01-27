extends Node2D

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		#get_tree().create_tween().tween_property(self, "global_position:y", 50, 2)
		var target = global_position.y + 500
		get_tree().create_tween().tween_property(self, "global_position:y", target, 3)
