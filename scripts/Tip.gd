extends Area2D
class_name HookTip
@export var player: Player
@export var links: Sprite2D

const HOOK_STRETCH_SPEED = 6
const HOOK_RETRACT_SPEED = -8
const MAXIMUM_TIME = 0.3
const COOLDOWN_TIME = 0.5

var isStreching: bool = false
var isFixed: bool = false
var isRetracting: bool = false
var isActivated: bool = false


var pointOfContact = null
var circleRadius = null
var target = null
var strechingTime = 0.0
var cooldownTime = 0.0
var speed = 0

func _ready():
	connect("body_entered", body_entered_hook)

func _process(delta):
	cooldownTime = max(cooldownTime - delta, 0.0)
	
	if not isActivated:
		return
	
	var hookLength = position.length()
	links.region_rect = Rect2(0, 0, 16, hookLength)
	links.offset.y = hookLength / 2.0
	
	if isStreching:
		strechingTime += delta
		
		if strechingTime >= MAXIMUM_TIME:
			start_retracting()
	
	if isStreching or isRetracting:
		position.x += speed
	
	if position.x <= 0:
		position.x = 0
		isRetracting = false
		deActivate()
	
	
	if Input.is_action_just_released("hook"):
		start_retracting()
	
	

func activate(direction: Vector2):
	cooldownTime = 10000.0
	target = direction
	
	isRetracting = false
	isStreching = true
	isFixed = false
	
	strechingTime = 0.0
	speed = HOOK_STRETCH_SPEED
	
	links.region_rect = Rect2(0, 0, 16, 0)
	
	get_parent().look_at(target)
	look_at(target)
	
	get_parent().visible = true
	isActivated = true

func deActivate():
	get_parent().visible = false
	position = Vector2.ZERO
	isRetracting = false
	isStreching = false
	isFixed = false
	
	target = null
	strechingTime = 0.0
	
	speed = 0.0
	
	links.region_rect = Rect2(0, 0, 16, 0)
	isActivated = false
	cooldownTime = COOLDOWN_TIME

func canUseHook() -> bool:
	return isStreching == false and isFixed == false and isRetracting == false and cooldownTime == 0.0

func body_entered_hook(body):
	if body.is_in_group("map") and isStreching:
		isRetracting = false
		isStreching = false
		isFixed = true
		pointOfContact = body.global_position
		circleRadius = (player.global_position - pointOfContact).length()

func getNewVelocity() -> Vector2:
	if not isFixed:
		return player.velocity
	var isInsideCircle = (player.global_position - pointOfContact).length() <= circleRadius
	if isInsideCircle:
		return player.velocity
	
	#print("shouldnt be here")
	
	var H = pointOfContact -  player.global_position
	var N = H.rotated(PI/2) if player.velocity.x >= 0 else H.rotated(-PI/2)
	var V = player.velocity
	var newV = V.project(N)
	return newV
	

func start_retracting():
	strechingTime = 0.0
	isStreching = false
	isRetracting = true
	speed = HOOK_RETRACT_SPEED

#$HookHand/Hook.visible = true
#var mousePosition = get_global_mouse_position()
#var hookVector = (mousePosition - $HookHand.global_position as Vector2)
#var hookVectorLength = hookVector.length() * 2 - 8
#$HookHand/Hook/Links.region_rect = Rect2(0, 0, 16, hookVectorLength)
#$HookHand/Hook/Links.offset.y = hookVectorLength / 2
#$HookHand/Hook/Tip.position.x = hookVectorLength
#$HookHand/Hook.look_at(mousePosition)
