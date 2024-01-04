extends CharacterBody2D

@onready var dustParticleRaw = load("res://particles/dust_particle_auto_dying.tscn")

const SPEED = 100.0
const JUMP_VELOCITY = -140.0
const ACCELERATION = 1.0
const DASH_FORCE = 250.0


var gravity = 400.0
var numberOfJumps = 1
var jumpCooldown = 0.2
var isTouchingWall = false

var isJumpBuffered = false
var wasOnFloor: bool = true
var jumpBufferTime = 0.2
var halfGravityThreshold = 50
var dashCooldown = 1.0
var sideParticle : float = 0.05


func _physics_process(delta):
	handle_animation()
	environmental_death()
	refresh_variables(delta)
	
	var isPlayerAgainstWall = get_is_player_against_wall()
	handle_wall_jump_metroid()
	
	# Add the gravity.
	if not is_on_floor():
		var gravityForce = 0.1 if isPlayerAgainstWall and velocity.y > 0 else 1.0
		if isHalfGravityThreshold():
			gravityForce = 0.5
		velocity.y += gravity * delta * gravityForce
		if Input.is_action_pressed("down"):
			velocity.y += gravity * delta
	
	# Handle jump.
	if is_on_floor():
		numberOfJumps = 1

	if canJump():
		$JumpSound.play()
		if is_on_floor() or not is_on_wall():
			$JumpParticle.restart()
		velocity.y = JUMP_VELOCITY
		numberOfJumps = 0
		jumpCooldown = 0.2
		isJumpBuffered = false
		$JumpSound.pitch_scale = 1.0
	
	if Input.is_action_just_released("jump") and velocity.y < JUMP_VELOCITY/10:
		velocity.y = JUMP_VELOCITY/10
	
	if Input.is_action_just_pressed("jump") and not is_on_floor() and not is_on_wall():
		isJumpBuffered = true
		jumpBufferTime = 0.2

	#handle_wall_jump(isPlayerAgainstWall)
	wall_slide_particle(delta, isPlayerAgainstWall)
	handle_movement(delta)
	handle_dash(delta)
	squish_and_squash()
	handle_landing_particle()
	
	isTouchingWall = is_on_wall()
	wasOnFloor = is_on_floor()

func wall_slide_particle(delta, isPlayerAgainstWall) -> void:
	sideParticle = max(sideParticle - delta, 0.0)
	if sideParticle > 0.0 or is_on_floor():
		return

	var leftSide = check_side_wall($LeftRayCast, Input.is_action_pressed("left"))
	var rightSide = check_side_wall($RightRayCast, Input.is_action_pressed("right"))
	
	if not leftSide and not rightSide:
		return
	
	
	sideParticle = 0.05
	var dustParticle = dustParticleRaw.instantiate()
	add_sibling(dustParticle)
	
	if leftSide:
		dustParticle.global_position = $LeftWallJump.global_position
	else:
		dustParticle.global_position = $RightWallJump.global_position

func handle_wall_jump_metroid() -> void:
	var leftSide = check_wall_jump_metroid($LeftRayCast, Input.is_action_pressed("right"))
	var rightSide = check_wall_jump_metroid($RightRayCast, Input.is_action_pressed("left"))
	
	if not leftSide and not rightSide:
		return

	var newVelocity = velocity
	var wallJumpHorizontalForce = 100
	var dustParticle = dustParticleRaw.instantiate()
	add_sibling(dustParticle)
	
	if rightSide:
		newVelocity = Vector2(-wallJumpHorizontalForce, JUMP_VELOCITY)
		dustParticle.global_position = $RightWallJump.global_position
	elif leftSide:
		newVelocity = Vector2(wallJumpHorizontalForce, JUMP_VELOCITY)
		dustParticle.global_position = $LeftWallJump.global_position
		
	
	jumpCooldown = 0.1
	isJumpBuffered = false
	$JumpSound.play()
	$JumpSound.pitch_scale = 0.7
	velocity = newVelocity

func check_wall_jump_metroid(rayCast, isButtonPressed) -> bool:
	# in the air, raycast is colliding, is pressing the other direction, is pressing jump
	return not is_on_floor() and rayCast.is_colliding() and rayCast.get_collider().is_in_group("map") and isButtonPressed and (Input.is_action_just_pressed("jump") or isJumpBuffered)

func handle_wall_jump(isPlayerAgainstWall) -> void:
	if isPlayerAgainstWall and (not is_on_floor()) and (Input.is_action_just_pressed("jump") or isJumpBuffered):
		isJumpBuffered = false
		var directionAgainstWall = get_direction_against_wall()
		var wallJumpHorizontalForce = -100
		velocity = Vector2(directionAgainstWall * wallJumpHorizontalForce, JUMP_VELOCITY)

func handle_dash(delta) -> void:
	if not Input.is_action_just_pressed("dash") or dashCooldown > 0.0:
		return
	get_parent().get_node("Camera2D").apply_shake()
	dashCooldown = 1.0
	$DashSound.play()
	$DashParticle.restart()
	var directionX = Input.get_axis("left", "right")
	var directionY = Input.get_axis("up", "down")
	velocity = Vector2(directionX, directionY).normalized() * Vector2(1.0, 0.75) * DASH_FORCE

func handle_movement(delta) -> void:
	var direction = Input.get_axis("left", "right")
	var targetSpeed = direction * SPEED
	var speedDif = targetSpeed - velocity.x
	
	var movement = speedDif * 0.1
	
	velocity.x += movement
	move_and_slide()

func appr(val, target, amount) -> float:
	if val > target:
		return max(val - amount, target)
	else:
		return min(val + amount, target)

func environmental_death() -> void:
	if global_position.y > 1000:
		get_tree().reload_current_scene()

func refresh_variables(delta) -> void:
	dashCooldown = max(dashCooldown-delta, 0.0)
	jumpCooldown = max(jumpCooldown-delta, 0.0)
	jumpBufferTime -= delta
	if jumpBufferTime <= 0:
		jumpBufferTime = 0.2
		isJumpBuffered = false

func canJump() -> bool:
	return (Input.is_action_just_pressed("jump") or isJumpBuffered) and numberOfJumps > 0 and jumpCooldown <= 0

func isHalfGravityThreshold() -> bool:
	return abs(velocity.y) < halfGravityThreshold

func handle_animation() -> void:
	if abs(velocity.x) < 20:
		$AnimatedSprite2D.play("idle")
	if abs(velocity.x) >= 20:
		$AnimatedSprite2D.play("running")
	
	if not is_on_floor():
		$AnimatedSprite2D.play("jumping")
	
	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
	elif velocity.x < 0:
		$AnimatedSprite2D.flip_h = true

func squish_and_squash() -> void:
	var maxX = DASH_FORCE * 1.5
	var maxY = DASH_FORCE * 1.5
	
	var newScaleY = 1 - min(abs(velocity.x), maxX) / maxX * 0.5
	var newScaleX = 1 - min(abs(velocity.y), maxY) / maxY * 0.5
	
	var sum = newScaleX + newScaleY
	if sum < 2.0:
		if newScaleX > newScaleY:
			newScaleX += 2 - sum
		else:
			newScaleY += 2 - sum

	$AnimatedSprite2D.scale.x = lerp($AnimatedSprite2D.scale.x, newScaleX, 0.2)
	$AnimatedSprite2D.scale.y = lerp($AnimatedSprite2D.scale.y, newScaleY, 0.2)

func get_direction_against_wall() -> float:
	if check_side_wall($LeftRayCast, Input.is_action_pressed("left")):
		return -1.0
	else:
		return 1.0

func get_is_player_against_wall() -> bool:
	var leftSide = check_side_wall($LeftRayCast, Input.is_action_pressed("left"))
	var rightSide = check_side_wall($RightRayCast, Input.is_action_pressed("right"))
	return leftSide or rightSide

func check_side_wall(rayCast, isButtonPressed) -> bool:
	if (not rayCast.is_colliding()) or isButtonPressed == false:
		return false
	return rayCast.get_collider().is_in_group("map")

func handle_landing_particle():
	if is_on_floor() and not wasOnFloor:
		$LandingParticle.restart()
