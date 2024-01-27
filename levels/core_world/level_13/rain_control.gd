extends Node2D

@export var player: Player
var activated : bool = false

func _physics_process(delta):
	if not activated:
		if player.velocity != Vector2.ZERO:
			activated = true
	else:
		player.velocity.x += 2
