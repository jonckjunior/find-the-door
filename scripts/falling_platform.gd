extends Node2D

var tweenPosition: Tween
var tweenCollision: Tween

func _on_area_2d_body_entered(body):
	#reset()
	if body.is_in_group("player"):
		var target = global_position.y + 1000
		tweenPosition = get_tree().create_tween()
		tweenPosition.tween_property(self, "global_position:y", target, 5).set_delay(0.2)
		
		tweenCollision = get_tree().create_tween()
		tweenCollision.tween_callback($Sprite2D/StaticBody2D/CollisionShape2D.set_deferred.bind("disabled", true)).set_delay(0.2)

func reset():
	if tweenCollision:
		tweenCollision.kill()
	if tweenPosition:
		tweenPosition.kill()
	
	$Sprite2D/StaticBody2D/CollisionShape2D.set_deferred("disabled", false)
