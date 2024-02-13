extends Area2D

@export var WIND_STRENGTH = 5.0
var target: Player = null


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", body_entered_area)
	connect("body_exited", body_exited_area)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target != null:
		target.velocity.x += WIND_STRENGTH

func body_entered_area(body):
	if body.is_in_group("player"):
		target = body

func body_exited_area(body):
	if body.is_in_group("player"):
		target = null
