extends CharacterBody2D
class_name Player

@onready var dustParticleRaw = load("res://particles/dust_particle_auto_dying.tscn")
@onready var deathParticleRaw = load("res://particles/death_particle.tscn")
@onready var playerDeathRaw = load("res://objects/player_death.tscn")
@onready var dash_trail_scene = load("res://objects/DashTrailScene.tscn")
@onready var hookHand: Marker2D = $HookHand

@export var canPlayerMove: bool = true
@export var dashUnlocked: bool = false
@export var wallSlideUnlocked: bool = false
@export var wallJumpUnlocked: bool = false
@export var isJumpUnlocked: bool = false
@onready var displacementRayCastsUp: Array[RayCast2D] = [$RayCasts/UpRayCast1, $RayCasts/UpRayCast2, $RayCasts/UpRayCast3, $RayCasts/UpRayCast4, $RayCasts/UpRayCast5, $RayCasts/UpRayCast6]
@onready var displacementRayCastsDown: Array[RayCast2D] = [$RayCasts/DownRayCast1, $RayCasts/DownRayCast2, $RayCasts/DownRayCast3, $RayCasts/DownRayCast4, $RayCasts/DownRayCast5, $RayCasts/DownRayCast6]
@export var hook: GrapplingHook

# CONST
const SPEED = 300.0
const JUMP_VELOCITY = -142.0
const WALL_JUMP_VELOCITY = -152 - 15.0
const ACCELERATION = 1.0
const DASH_FORCE = 40.0
const gravity = 460.0
const HALF_GRAVITY_THRESHOLD = 25
const ADJUST_FEET_CORNER_LIMIT = 100
const ADJUST_HEAD_CORNER_LIMIT = -100
const ADJUST_HEAD_CORNER_LIMIT_DASH = 100
const DEAD_INPUT_THRESHOLD = 0.05
const BOOST_CORNER_ADJUSTMENT = 50
const BASE_DASH_COOLDOWN = 0.2
const MAX_FALL_SPEED = 300.0
const DASH_CORRECTION_TIME_BASE = 0.1
const DIRECTIONAL_BUFFER_TIME_BASE = 0.2
const PLAYER_AGAINS_WALL_TIME_BASE = 10.0
const SUPER_DASH_HORIZONTAL_BOOST = -45.0
const SUPER_DASH_VERTICAL = 40
const SUPER_DASH_VERTICAL_HORIZONTAL_BOOST = -80
const VERTICAL_GRAVITY = 80
const IS_SUPER_DASHING_TIME = 0.25
const SUPER_DASH_WALLJUMP = -15

# COIN
var coin: Coin = null

# PLAYER STATS
var numberOfJumps = 1
var numberOfDashes = 1

# COOLDOWNS
var isDashingCooldown = 0.2
var jumpCooldown = 0.2
var jumpBufferTime = 0.2
var dashCooldown = 1.0
var sideParticleCooldown : float = 0.05
var runningSoundCooldown: float = 0.2
var trailCooldown: float = 0.05
var dashCorrectionTime: float = 0.0
var directionalRightBufferTime = 0.0
var directionalLeftBufferTime = 0.0
var playerAgainstWallTimer = 0.0
var timeSinceDash = 0.0
var timeSinceFloor = 0.0


# FLAGS
var isTouchingWall = false
var isJumpBuffered = false
var wasOnFloor: bool = true
var isDying: bool = false
var isDashing: bool = false
var isJumping: bool = false
var isDashGrounded: bool = false
var crouchedDash: bool = false
var dashAngle: Vector2 = Vector2.ZERO
var isSwinging: bool = false


var superDashingTimer: float = 0.0
var isHyperDashingTimer: float = 0.0

var dashForce: Vector2 = Vector2.ZERO

# SIGNALS
signal player_death
signal dash

func _ready():
	$AnimatedSprite2D.play("idle")
	dashUnlocked = get_node("/root/GameVariables").dashUnlocked
	wallSlideUnlocked = get_node("/root/GameVariables").wallSlideUnlocked
	wallJumpUnlocked = get_node("/root/GameVariables").wallJumpUnlocked
	isJumpUnlocked = get_node("/root/GameVariables").isJumpUnlocked
	canPlayerMove = get_node("/root/GameVariables").canPlayerMove

func _physics_process(delta):
	if isDying:
		return
	
	if velocity.y >= 0:
		dashForce.y = 0	

	#dashForce.x *= pow(0.15, delta)
	#dashForce.x = sign(dashForce.x) * max(abs(dashForce.x) - 20 * delta, 0.0)
	dashForce.x = sign(dashForce.x) * max(abs(dashForce.x) - 100 * delta, 0.0)
	dashForce.y = sign(dashForce.y) * max(abs(dashForce.y) - 220 * delta, 0.0)
	
	if Input.is_action_just_pressed("death"):
		die()
	
	if Input.is_action_pressed("left"):
		directionalLeftBufferTime = DIRECTIONAL_BUFFER_TIME_BASE
	if Input.is_action_just_pressed("right"):
		directionalRightBufferTime = DIRECTIONAL_BUFFER_TIME_BASE

	handle_dash_trail()
	handle_dash_visual()
	adjust_head_corner()
	adjust_head_dash_corner()
	adjust_feet_dash_corner()
	
	handle_animation()
	environmental_death()
	refresh_variables(delta)
	
	if is_on_floor():
		timeSinceFloor = 0.0
	
	var isPlayerAgainstWall = get_is_player_against_wall()
	handle_wall_jump_metroid()
	
	if not isPlayerAgainstWall:
		playerAgainstWallTimer = PLAYER_AGAINS_WALL_TIME_BASE
	else:
		playerAgainstWallTimer = max(playerAgainstWallTimer - delta, 0.0)
	
	# Add the gravity.
	if not is_on_floor() and not isDashing:
		if isPlayerAgainstWall and velocity.y > 0 and wallSlideUnlocked:
			velocity.y += gravity * delta
			if get_input("down"):
				velocity.y += gravity * delta
			velocity.y *= 0.8
		else:
			var gravityForce = 0.5 if isHalfGravityThreshold() and not (hook and hook.isFixed) else 1.0
			velocity.y += gravity * delta * gravityForce
			if not (hook and hook.isFixed) and get_input("down"):
				velocity.y += gravity * delta * 0.5
	
	# Handle jump.
	if is_on_floor():
		numberOfJumps = 1
		isSwinging = false
		if isDashingCooldown < 0.1:
			numberOfDashes = 1

	handle_jump()
	
	if Input.is_action_just_released("jump") and isJumping and velocity.y < JUMP_VELOCITY/3:
		velocity.y = JUMP_VELOCITY/3
	
	if get_input_just_pressed("jump") and not is_on_floor() and not is_on_wall():
		isJumpBuffered = true
		jumpBufferTime = 0.2

	wall_slide_particle(delta)
	handle_dash(delta)
	handle_movement(delta)
	squish_and_squash()
	handle_landing_particle()
	running_audio(delta)
	clamp_velocity()
	
	isTouchingWall = is_on_wall()
	wasOnFloor = is_on_floor()

func handle_jump() -> void:
	var isDashAngleBad = deg_to_rad(-180 + 30) < dashAngle.angle() and dashAngle.angle() < deg_to_rad(0 - 30)
	
	if canJump() and isDashing and timeSinceDash <= 0.2 and not isDashAngleBad and superDashingTimer == 0.0: #and leftRayCast.is_colliding() and leftRayCast.get_collider().is_in_group("map") and not rightRayCast.is_colliding():
		#if isDashing:
			#super dash-jump
		if crouchedDash:
			print("tipo 1")
			superDashingTimer = IS_SUPER_DASHING_TIME
			print("dashForce = ", dashForce)
			print("velocity = ", velocity)
			dashForce.x *= 1.1
			#get_tree().create_tween().tween_property(self, "dashForce", dashForce + Vector2(SUPER_DASH_VERTICAL * (-1 if $AnimatedSprite2D.flip_h else 1) * 1.8, 0.0), 0.1)
			dashForce += Vector2(SUPER_DASH_VERTICAL * (-1 if $AnimatedSprite2D.flip_h else 1) * 1.3, -28)
			velocity.y = 0
			isJumpBuffered = false
			
		else:
			print("tipo 2")
			print("dashForce = ", dashForce)
			print("velocity = ", velocity)
			superDashingTimer = IS_SUPER_DASHING_TIME
			
			dashForce += Vector2(SUPER_DASH_VERTICAL * (-1 if $AnimatedSprite2D.flip_h else 1), -34)
			velocity.y = 0
			isJumpBuffered = false
	elif canJump() and (is_on_floor() or (timeSinceFloor < 0.2 and timeSinceDash > 0.5)):
		print("normal jump")
		$JumpSound.play()
		if is_on_floor() or not is_on_wall():
			$JumpParticle.restart()
		velocity.y = JUMP_VELOCITY
		dashForce = Vector2.ZERO
		isJumping = true
		numberOfJumps = 0
		jumpCooldown = 0.2
		isJumpBuffered = false

func wall_slide_particle(delta) -> void:
	sideParticleCooldown = max(sideParticleCooldown - delta, 0.0)
	if sideParticleCooldown > 0.0 or is_on_floor():
		return
	
	if not wallSlideUnlocked:
		return

	var leftSide = check_side_wall($RayCasts/LeftRayCast, get_input("left"))
	var rightSide = check_side_wall($RayCasts/RightRayCast, get_input("right"))
	
	if not leftSide and not rightSide:
		return
	
	
	sideParticleCooldown = 0.1
	var dustParticle = dustParticleRaw.instantiate()
	add_sibling(dustParticle)
	
	if leftSide:
		dustParticle.global_position = $LeftWallJump.global_position
	else:
		dustParticle.global_position = $RightWallJump.global_position

func handle_wall_jump_metroid() -> void:
	if not wallJumpUnlocked or jumpCooldown > 0.0:
		return
	#var leftSide = check_wall_jump_metroid($RayCasts/LeftRayCast, get_input("right") or directionalRightBufferTime > 0.0) or check_wall_jump_metroid($RayCasts/LeftRayCastWallJumpDown, get_input("right") or directionalRightBufferTime > 0.0) or check_wall_jump_metroid($RayCasts/LeftRayCastWallJumpUp, get_input("right") or directionalRightBufferTime > 0.0)
	#var rightSide = check_wall_jump_metroid($RayCasts/RightRayCast, get_input("left") or directionalLeftBufferTime > 0.0) or check_wall_jump_metroid($RayCasts/RightRayCastWallJumpDown, get_input("left") or directionalLeftBufferTime > 0.0) or check_wall_jump_metroid($RayCasts/RightRayCastWallJumpUp, get_input("left") or directionalLeftBufferTime > 0.0)
	var leftSide = check_wall_jump_metroid($RayCasts/LeftRayCast, get_input("right") or directionalRightBufferTime > 0.0) or check_wall_jump_metroid($RayCasts/LeftRayCastWallJumpDown, get_input("right")) or check_wall_jump_metroid($RayCasts/LeftRayCastWallJumpUp, get_input("right"))
	var rightSide = check_wall_jump_metroid($RayCasts/RightRayCast, get_input("left") or directionalLeftBufferTime > 0.0) or check_wall_jump_metroid($RayCasts/RightRayCastWallJumpDown, get_input("left")) or check_wall_jump_metroid($RayCasts/RightRayCastWallJumpUp, get_input("left"))
	
	if not leftSide and not rightSide:
		return

	var newVelocity = velocity
	var wallJumpHorizontalForce = 100
	var dustParticle = dustParticleRaw.instantiate()
	add_sibling(dustParticle)
	
	var newVelocityY: float

	if timeSinceDash < 0.4:
		print("dashForce = ", dashForce)
		if timeSinceDash < 0.1:
			dashForce.y += SUPER_DASH_WALLJUMP * 1.0
			if dashForce.y > -50:
				dashForce.y = max(dashForce.y, -35)
			print("timeSinceDash < 0.1:")
		elif timeSinceDash < 0.2:
			dashForce.y += SUPER_DASH_WALLJUMP * 1.6
			print("timeSinceDash < 0.2:")
		elif timeSinceDash < 0.3:
			dashForce.y += SUPER_DASH_WALLJUMP * 1.7
			print("timeSinceDash < 0.3:")
		else:
			dashForce.y += SUPER_DASH_WALLJUMP * 1.8
			print("timeSinceDash < 0.4:")
		print("dashForce = ", dashForce)
	
	if rightSide:
		newVelocity = Vector2(-wallJumpHorizontalForce, WALL_JUMP_VELOCITY)
		dustParticle.global_position = $RightWallJump.global_position
	elif leftSide:
		newVelocity = Vector2(wallJumpHorizontalForce, WALL_JUMP_VELOCITY)
		dustParticle.global_position = $LeftWallJump.global_position
	
	jumpCooldown = 0.2
	isJumpBuffered = false
	$WallJumpSound.play()
	velocity = newVelocity

func check_wall_jump_metroid(rayCast, isButtonPressed) -> bool:
	# in the air, raycast is colliding, is pressing the other direction, is pressing jump
	return not is_on_floor() and rayCast.is_colliding() and rayCast.get_collider().is_in_group("map") and isButtonPressed and (get_input_just_pressed("jump") or isJumpBuffered)

func handle_dash(delta) -> void:
	if not get_input_just_pressed("dash") or dashCooldown > 0.0 or not dashUnlocked or numberOfDashes <= 0:
		return
	
	crouchedDash = get_input("down")
	isDashGrounded = is_on_floor()
	isJumping = false
	numberOfDashes = 0
	dash.emit()
	dashCooldown = BASE_DASH_COOLDOWN
	$DashSound.play()
	$DashParticle.restart()
	var directionX = get_input_axis("left", "right")
	var directionY = get_input_axis("up", "down")
	if abs(directionX) < DEAD_INPUT_THRESHOLD and abs(directionY) < DEAD_INPUT_THRESHOLD:
		directionX = -1 if $AnimatedSprite2D.flip_h else 1
	
	var currentDashForce = Vector2(directionX, directionY).normalized() * DASH_FORCE * Vector2(1.0, 1.0)
	currentDashForce.y = max(currentDashForce.y, -35)
	
	if sign(currentDashForce.x) != sign(dashForce.x):
		dashForce.x = currentDashForce.x
	else:
		dashForce.x += currentDashForce.x
	
	if sign(currentDashForce.y) != sign(dashForce.y):
		dashForce.y = currentDashForce.y
	else:
		dashForce.y += currentDashForce.y
	
	velocity = Vector2.ZERO

	dashAngle = Vector2(directionX, directionY)
	isDashing = true
	isDashingCooldown = 0.2
	dashCorrectionTime = DASH_CORRECTION_TIME_BASE
	timeSinceDash = 0.0

	print("dashForce = ", dashForce)
	print("velocity = ", velocity)

func handle_movement(delta) -> void:
	var direction = sign(dashForce.x) if absf(dashForce.x) > 20 else get_input_axis("left", "right")
	var targetSpeed = direction * 0.35 * get_max_speed()
	
	var speedDif = targetSpeed - velocity.x
	
	var movement = speedDif * (0.10 if isSwinging else 0.15)
	
	#if hook and hook.isFixed:
		#movement = 0
	
	
	if absf(direction) < 0.1 and hook and hook.isFixed:
		movement = 0
	
	if absf(direction) > 0.1 and hook and hook.isFixed:
		movement = direction * delta * 30
	
	velocity.x += movement
	velocity += dashForce
	
	if hook and hook.isFixed:
		velocity = hook.get_new_velocity(velocity, delta)
	
	move_and_slide()

func get_max_speed() -> float:
	if isSwinging:
		return SPEED * 1.5
	else:
		return SPEED

func appr(val, target, amount) -> float:
	if val > target:
		return max(val - amount, target)
	else:
		return min(val + amount, target)

func environmental_death() -> void:
	if global_position.y > 1000.0:
		get_tree().reload_current_scene()

func refresh_variables(delta) -> void:
	timeSinceFloor += delta
	timeSinceDash += delta
	superDashingTimer = max(superDashingTimer-delta, 0.0)
	directionalLeftBufferTime = max(directionalLeftBufferTime-delta, 0.0)
	directionalRightBufferTime = max(directionalRightBufferTime-delta, 0.0)
	dashCooldown = max(dashCooldown-delta, 0.0)
	jumpCooldown = max(jumpCooldown-delta, 0.0)
	trailCooldown = max(trailCooldown-delta, 0.0)
	dashCorrectionTime = max(dashCorrectionTime-delta, 0.0)
	jumpBufferTime -= delta
	if jumpBufferTime <= 0:
		jumpBufferTime = 0.2
		isJumpBuffered = false
	
	isDashingCooldown -= delta
	if isDashingCooldown < 0:
		isDashing = false
		isDashingCooldown = 0

func canJump() -> bool:
	return (get_input_just_pressed("jump") or isJumpBuffered) and numberOfJumps > 0 and jumpCooldown <= 0 and isJumpUnlocked and timeSinceFloor < 0.2

func isHalfGravityThreshold() -> bool:
	return abs(velocity.y) < HALF_GRAVITY_THRESHOLD

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
	var maxX = 300
	var maxY = DASH_FORCE * 5.5
	
	var newScaleY = 1 - min(abs(velocity.x), maxX) / maxX * 0.5
	var newScaleX = 1 - min(abs(velocity.y), maxY) / maxY * 0.5
	
	var sum = newScaleX + newScaleY
	if sum < 2:
		if newScaleX >= newScaleY:
			newScaleX += 2 - sum
		else:
			newScaleY += 2 - sum

	$AnimatedSprite2D.scale.x = snapped(lerp($AnimatedSprite2D.scale.x, newScaleX, 0.2), 0.04)
	$AnimatedSprite2D.scale.y = snapped(lerp($AnimatedSprite2D.scale.y, newScaleY, 0.2), 0.04)

func get_is_player_against_wall() -> bool:
	var leftSide = check_side_wall($RayCasts/LeftRayCast, get_input("left"))
	var rightSide = check_side_wall($RayCasts/RightRayCast, get_input("right"))
	return leftSide or rightSide

func check_side_wall(rayCast, isButtonPressed) -> bool:
	if (not rayCast.is_colliding()) or isButtonPressed == false:
		return false
	return rayCast.get_collider().is_in_group("map")

func handle_landing_particle():
	if is_on_floor() and not wasOnFloor:
		$LandingParticle.restart()
		$LandingSound.play()

func give_controllers_back():
	canPlayerMove = true

func take_controllers_away():
	canPlayerMove = false

func get_input(inputStr):
	if canPlayerMove:
		return Input.is_action_pressed(inputStr)
	else:
		return false

func get_input_just_pressed(inputStr):
	if canPlayerMove:
		return Input.is_action_just_pressed(inputStr)
	else:
		return false

func get_input_axis(first, second):
	if canPlayerMove:
		return Input.get_axis(first, second)
	else:
		return 0.0

func die():
	if isDying:
		return
	velocity = Vector2(0, 0)
	dashForce = Vector2(0, 0)
	player_death.emit()
	$DeathSound.play()
	isDying = true

	take_controllers_away()
	
	dashCooldown = 0.0
	jumpCooldown = 0.0
	isJumpBuffered = false
	
	visible = false
	var deathScene = playerDeathRaw.instantiate()
	deathScene.global_position = global_position
	add_sibling(deathScene)
	
	var deathParticle = deathParticleRaw.instantiate()
	deathParticle.global_position = global_position
	deathParticle.restart()
	add_sibling(deathParticle)
	

func respawn_player(respawnPosition):
	isDying = false
	velocity = Vector2(0, 0)
	global_position = respawnPosition
	give_controllers_back()
	visible = true
	print("deu respawn")

func running_audio(delta):
	runningSoundCooldown = max(runningSoundCooldown - delta, 0.0)
	if not is_on_floor() or $AnimatedSprite2D.animation != "running":
		$RunningSound.stop()
	if is_on_floor() and $AnimatedSprite2D.animation == "running" and not $RunningSound.playing and runningSoundCooldown == 0.0 and abs(velocity.x) > 40:
		$RunningSound.play()
		runningSoundCooldown = 0.2

func adjust_head_dash_corner():
	if not isDashing or isDashGrounded:
		return
	
	var headRightCollided = velocity.x > ADJUST_HEAD_CORNER_LIMIT_DASH and is_colliding_with_map($RayCasts/RightUpRayCastDash) and not is_colliding_with_map($RayCasts/RightRayCastDash) and isDashing
	var headLeftCollided = velocity.x < -ADJUST_HEAD_CORNER_LIMIT_DASH and is_colliding_with_map($RayCasts/LeftUpRayCastDash) and not is_colliding_with_map($RayCasts/LeftRayCastDash) and isDashing
	
	var feetRightCollided = velocity.x > ADJUST_HEAD_CORNER_LIMIT_DASH and is_colliding_with_map($RayCasts/RightDownRayCastDash) and not is_colliding_with_map($RayCasts/RightRayCastDash) and isDashing
	var feetLeftCollided = velocity.x < -ADJUST_HEAD_CORNER_LIMIT_DASH and is_colliding_with_map($RayCasts/LeftDownRayCastDash) and not is_colliding_with_map($RayCasts/LeftRayCastDash) and isDashing
	
	if headRightCollided or headLeftCollided:
		global_position.y += abs($RayCasts/RightRayCastDash.position.y - $RayCasts/RightUpRayCastDash.position.y)
		velocity.x += BOOST_CORNER_ADJUSTMENT if headRightCollided else -BOOST_CORNER_ADJUSTMENT
	elif feetRightCollided or feetLeftCollided:
		global_position.y -= abs($RayCasts/RightRayCastDash.position.y - $RayCasts/RightUpRayCastDash.position.y)
		velocity.x += BOOST_CORNER_ADJUSTMENT if feetRightCollided else -BOOST_CORNER_ADJUSTMENT

func adjust_head_corner():
	if not isDashing or isDashGrounded:
		return

	if is_colliding_with_map($RayCasts/UpLeftRayCast):
		for x in range(3):
			if not is_colliding_with_map(displacementRayCastsUp[x]) and velocity.y < ADJUST_HEAD_CORNER_LIMIT and isDashing:
				global_position.x += displacementRayCastsUp[x].position.x - $RayCasts/UpLeftRayCast.position.x
				velocity.y -= BOOST_CORNER_ADJUSTMENT
				break
	elif is_colliding_with_map($RayCasts/UpRightRayCast):
		for x in [5, 4, 3]:
			if not is_colliding_with_map(displacementRayCastsUp[x]) and velocity.y < ADJUST_HEAD_CORNER_LIMIT and isDashing:
				global_position.x -= $RayCasts/UpRightRayCast.position.x - displacementRayCastsUp[x].position.x
				velocity.y -= BOOST_CORNER_ADJUSTMENT
				break

func adjust_feet_dash_corner():
	if not isDashing or isDashGrounded:
		return

	if is_colliding_with_map($RayCasts/DownLeftRayCast):
		for x in range(3):
			if not is_colliding_with_map(displacementRayCastsDown[x]) and velocity.y > ADJUST_FEET_CORNER_LIMIT and isDashing:
				global_position.x += displacementRayCastsDown[x].position.x - $RayCasts/DownLeftRayCast.position.x
				velocity.y += BOOST_CORNER_ADJUSTMENT
				break
	elif is_colliding_with_map($RayCasts/DownRightRayCast):
		for x in [5, 4, 3]:
			if not is_colliding_with_map(displacementRayCastsDown[x]) and velocity.y > ADJUST_FEET_CORNER_LIMIT and isDashing:
				global_position.x -= $RayCasts/DownRightRayCast.position.x - displacementRayCastsDown[x].position.x
				velocity.y += BOOST_CORNER_ADJUSTMENT
				break

func is_colliding_with_map(raycast: RayCast2D):
	return raycast.is_colliding() and raycast.get_collider().is_in_group("map")

func refresh_movement():
	numberOfJumps = 1
	numberOfDashes = 1

func handle_dash_trail():
	if isDashing and trailCooldown == 0.0:
		var trail_instance = dash_trail_scene.instantiate()
		add_sibling(trail_instance)
		trail_instance.transform = $AnimatedSprite2D.transform
		trail_instance.flip_h = $AnimatedSprite2D.flip_h
		trail_instance.modulate = Color("003737") # Color("003737")
		trail_instance.position = position
		trail_instance.texture = ($AnimatedSprite2D.sprite_frames as SpriteFrames).get_frame_texture($AnimatedSprite2D.animation, $AnimatedSprite2D.frame)
		trailCooldown = 0.05

func clamp_velocity():
	velocity.y = min(velocity.y, 250)
	velocity.y = max(velocity.y, -800)

func handle_dash_visual():
	return
	#$CharacterHorns.scale = $AnimatedSprite2D.scale
	#$CharacterHorns.modulate = Color("bc2121")
	#$AnimatedSprite2D.modulate = Color("003737").lightened(0.5)
	#if numberOfDashes == 0:
		#$CharacterHorns.modulate = Color("bc2121").lerp("FFFFFF", 0.2)
	#else:
		##var weight = (BASE_DASH_COOLDOWN - dashCooldown) / BASE_DASH_COOLDOWN
		#$CharacterHorns.modulate = Color("bc2121").lerp("FFFFFF", 1)
