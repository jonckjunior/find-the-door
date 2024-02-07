extends Sprite2D

@onready var staticCollision = $StaticBody2D/CollisionShape2D
@onready var areaPlayer = $AreaPlayer
@onready var areaStopper = $AreaStopper

const RISING_VELOCITY: float = 30.0
const LAST_TOUCH_TREHSHOLD = 400.0

var activated: bool = false
var lastTouchTimer: float = LAST_TOUCH_TREHSHOLD
var touchedCeiling: bool = false

func _ready():
	areaPlayer.connect("body_entered", on_body_entered)
	areaPlayer.connect("body_exited", on_body_exited)
	
	areaStopper.connect("body_entered", on_body_enter_stopper)

func _process(delta):
	if lastTouchTimer < LAST_TOUCH_TREHSHOLD and not touchedCeiling:
		position.y -= RISING_VELOCITY * delta
	
	if activated == false:
		lastTouchTimer = min(lastTouchTimer + delta, LAST_TOUCH_TREHSHOLD)

func on_body_enter_stopper(body):
	if body.is_in_group("map"):
		touchedCeiling = true

func on_body_entered(body):
	if body.is_in_group("player") and not body.isDying:
		activated = true
		lastTouchTimer = 0.0

func on_body_exited(body):
	if body.is_in_group("player") and not body.isDying:
		activated = false

func reset():
	touchedCeiling = false
	activated = false
	lastTouchTimer = LAST_TOUCH_TREHSHOLD + 0.5
	$AreaPlayer/CollisionShape2D.set_deferred("disabled", true)
	var tween = get_tree().create_tween()
	tween.tween_callback($AreaPlayer/CollisionShape2D.set_deferred.bind("disabled", false)).set_delay(0.3)
