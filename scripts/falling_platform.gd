extends Node2D

var tween: Tween

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		#get_tree().create_tween().tween_property(self, "global_position:y", 50, 2)
		var target = global_position.y + 250
		tween = get_tree().create_tween()
		tween.tween_property(self, "global_position:y", target, 2).set_delay(0.2)

func reset():
	if tween:
		tween.kill()
