extends Area2D

@onready var gameManager: GameManagerClass = get_node("/root/GameManager")

signal player_entered

func _ready():
	connect("body_entered", body_entered_zezin_trigger)

func body_entered_zezin_trigger(body):
	if body.is_in_group("player"):
		gameManager.enter_dialogue(body)
		player_entered.emit()
