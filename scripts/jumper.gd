extends AnimatedSprite2D

@onready var audioJumper = get_node("AudioJumper")

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		play("activate")
		audioJumper.play()
		body.velocity.y = min(body.velocity.y - 300, -300)
		body.refresh_movement()
		body.isJumping = false
		await get_tree().create_timer(0.3).timeout
