extends Area2D

signal kill_player

func _on_body_entered(body):
	if body.is_in_group("player") and body.isDying == false:
		kill_player.emit()
