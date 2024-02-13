extends Node2D

const SHAKING_STATE_TIME = 0.2
const STATIC_TIME = 0.2

var shakingState: bool = false
var shakingStateTimer: float = 0.0

var fallingState: bool = false

var staticTimer: float = 0.0


func _process(delta):
	staticTimer += delta
	
	if shakingState:
		shakingStateTimer += delta
	
	if shakingStateTimer > SHAKING_STATE_TIME:
		fallingState = true
		$Sprite2D/StaticBody2D/CollisionShape2D.set_deferred("disabled", true)
		shakingState = false
	
	if fallingState:
		global_position.y += 100 * delta

func _on_area_2d_body_entered(body):
	if body.is_in_group("player") and staticTimer > STATIC_TIME:
		shakingState = true
		print(body.global_position)
		print(global_position)

func reset():
	staticTimer = 0.0
	shakingState = false
	fallingState = false
	shakingStateTimer = 0.0
	
	$Sprite2D/StaticBody2D/CollisionShape2D.set_deferred("disabled", false)
