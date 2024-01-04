extends CharacterBody2D

@export var label_numberOfJumps : Label

const SPEED = 900.0
const JUMP_VELOCITY = -950.0
const ACCELERATION = 1.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 2.0
var numberOfJumps = 1
var jumpCooldown = 0.2
var airTime = 0.0
var isTouchingWall = false

var isJumpBuffered = false
var jumpBufferTime = 0.2
var halfGravityThreshold = 0

func _physics_process(delta):
	environmental_death()
	refresh_variables(delta)
	var isPlayerAgainsWall = Input.is_action_pressed("left") or Input.is_action_pressed("right")
	
	# Add the gravity.
	if not is_on_floor():
		var gravityForce = 0.1 if is_on_wall() and velocity.y > 0 and isPlayerAgainsWall else 1.0
		if isHalfGravityThreshold():
			gravityForce = 0.5
		velocity.y += gravity * delta * gravityForce
		if Input.is_action_pressed("down"):
			velocity.y += gravity * delta
	
	# Handle jump.
	if (is_on_wall() and isPlayerAgainsWall) or is_on_floor():
		numberOfJumps = 1

	if canJump():
		airTime = 0.0
		velocity.y = JUMP_VELOCITY
		numberOfJumps = 0
		jumpCooldown = 0.2
		isJumpBuffered = false
	
	if Input.is_action_just_released("ui_accept") and velocity.y < JUMP_VELOCITY/10:
		velocity.y = JUMP_VELOCITY/10
	
	if Input.is_action_just_pressed("ui_accept") and not is_on_floor() and not is_on_wall():
		isJumpBuffered = true
		jumpBufferTime = 0.2


	handle_movement(delta)
	isTouchingWall = is_on_wall()

func handle_movement(delta):
	var direction = Input.get_axis("left", "right")
	var targetSpeed = direction * SPEED
	var speedDif = targetSpeed - velocity.x
	
	var movement = speedDif * 0.1
	
	velocity.x += movement
	move_and_slide()

func celeste_movement(delta):
	var direction = Input.get_axis("left", "right")
	var targetSpeed = direction * SPEED
	var speedDif = targetSpeed - velocity.x
	var maxrun = 1000
	var accel = 600
	var deccel = 150
	
	if abs(velocity.x) > maxrun:
		velocity.x = appr(velocity.x, targetSpeed, deccel)
	else:
		velocity.x = appr(velocity.x, targetSpeed, accel)
	
	#var movkement = speedDif * 0.1
	
	#velocity.x += movement
	move_and_slide()

func appr(val, target, amount):
	if val > target:
		return max(val - amount, target)
	else:
		return min(val + amount, target)

func environmental_death():
	if global_position.y > 1000:
		get_tree().reload_current_scene()

func refresh_variables(delta):
	if not is_on_floor():
		airTime += delta
	else:
		airTime = 0.0
	jumpCooldown = max(jumpCooldown-delta, 0.0)
	jumpBufferTime -= delta
	if jumpBufferTime <= 0:
		jumpBufferTime = 0.2
		isJumpBuffered = false

func canJump():
	return (Input.is_action_just_pressed("ui_accept") or isJumpBuffered) and numberOfJumps > 0 and jumpCooldown <= 0

func isHalfGravityThreshold():
	return abs(velocity.y) < halfGravityThreshold
