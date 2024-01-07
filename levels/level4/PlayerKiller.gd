extends Node2D
class_name GameMaster2

@export var player: Player
@export var typewritter: RichTextLabel


var didPlayerFall: bool = false
const playerInitialPosition: Vector2 = Vector2(23, 168)

func kill_player(death_position):
	$Timer.wait_time = 0.0
	$Timer.start()
	player.instance_death()
	player.visible = false
	player.take_controllers_away()

func reset_typewritter():
	typewritter.reset()

func _on_timer_timeout():
	reset_typewritter()
	player.global_position = playerInitialPosition
	player.give_controllers_back()
	player.visible = true
	$Timer.stop()
