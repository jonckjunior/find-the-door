extends Node2D
class_name GameMaster

@export var camera: Camera2D
@export var player: Player
@export var typewritter: RichTextLabel
@export var respawnPosition: Vector2

signal fade_out_player_death
signal fade_in_player_respawn

func _on_player_player_death():	
	fade_out_player_death.emit()
	$RespawnTimer.start()
	camera.death_shake()


func _on_respawn_timer_timeout():
	fade_in_player_respawn.emit()
	typewritter.reset()
	player.respawn_player(respawnPosition)
	$RespawnTimer.stop()


func _on_player_dash():
	camera.apply_shake()

func _on_default_player_killer_kill_player():
	player.die()
