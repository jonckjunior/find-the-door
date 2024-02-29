extends Node2D


@onready var player: Player = get_parent().get_node("Player")

func _ready():
	get_parent().get_node("ZezinTrigger").connect("player_entered", give_player_hook)

func give_player_hook():
	get_node("/root/GameVariables").hookUnlocked = true
	player.hook.isActivated = true
