extends Node2D

var tween: Tween

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		var target = global_position.y + 1000
		tween = get_tree().create_tween()
		tween.tween_property(self, "global_position:y", target, 5).set_delay(0.2)
		tween.tween_callback($Sprite2D/StaticBody2D/CollisionShape2D.set_deferred.bind("disabled", true)).set_delay(0.2)


func reset():
	if tween:
		tween.kill()
		$Sprite2D/StaticBody2D/CollisionShape2D.set_deferred("disabled", false)
