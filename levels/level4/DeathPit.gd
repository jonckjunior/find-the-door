extends Area2D

@export var gameMaster: GameMaster

func _on_body_entered(body):
	if body.is_in_group("player"):
		gameMaster.kill_player(body.global_position)
