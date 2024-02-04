extends CharacterBody2D

@onready var staticCollision = $CollisionShape2D
@onready var area2d = $Area2D

const RISING_VELOCITY: float = 30.0
const LAST_TOUCH_TREHSHOLD = 1.0

var activated: bool = false
var lastTouchTimer: float = LAST_TOUCH_TREHSHOLD


func _ready():
	area2d.connect("body_entered", on_body_entered)
	area2d.connect("body_exited", on_body_exited)

func _process(delta):
	if lastTouchTimer < LAST_TOUCH_TREHSHOLD:
		print("andando", lastTouchTimer)
		velocity.y = -RISING_VELOCITY
		move_and_slide()
		#position.y -= RISING_VELOCITY * delta
	
	if activated == false:
		lastTouchTimer = min(lastTouchTimer + delta, LAST_TOUCH_TREHSHOLD)

func on_body_entered(body):
	if body.is_in_group("player") and not body.isDying:
		activated = true
		lastTouchTimer = 0.0

func on_body_exited(body):
	if body.is_in_group("player") and not body.isDying:
		activated = false

func reset():
	activated = false
	lastTouchTimer = LAST_TOUCH_TREHSHOLD + 0.5
	$Area2D/CollisionShape2D.set_deferred("disabled", true)
	var tween = get_tree().create_tween()
	tween.tween_callback($Area2D/CollisionShape2D.set_deferred.bind("disabled", false)).set_delay(0.3)
