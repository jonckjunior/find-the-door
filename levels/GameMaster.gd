extends Node2D
class_name GameMaster

@export var camera: Camera2D
@export var player: Player
@export var typewritter: RichTextLabel
@export var respawnPosition: Vector2

signal fade_out_player_death
signal fade_in_player_respawn

func _ready():
	respawnPosition = player.global_position

func _on_player_player_death():
	fade_out_player_death.emit()
	camera.death_shake()
	await get_tree().create_timer(0.5).timeout
	respawn_player()

func respawn_player():
	fade_in_player_respawn.emit()
	typewritter.reset()
	player.respawn_player(respawnPosition)

func _on_player_dash():
	camera.apply_shake()

func _on_default_player_killer_kill_player():
	if not player.isDying:
		player.die()
