extends Area2D

@export var upKeyButton: Sprite2D
var time: float = 0
var activated: bool = false
var canPressUpAndLeave: bool = false

signal player_passed_level

# Called when the node enters the scene tree for the first time.
func _ready():
	upKeyButton.modulate.a = 0

func _input(event):
	if event.is_action_pressed("up") and activated and canPressUpAndLeave:
		player_passed_level.emit()

func _process(delta):
	if activated:
		time += delta * 2
		upKeyButton.modulate.a = (sin(time) + 1) / 2

func _on_body_entered(body):
	if body.is_in_group("player"):
		activated = true
		canPressUpAndLeave = true


func _on_body_exited(body):
	if body.is_in_group("player"):
		activated = true
		canPressUpAndLeave = false
