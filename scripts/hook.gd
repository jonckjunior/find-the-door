extends Node2D
class_name GrapplingHook

@export var player: Player
@onready var links: Sprite2D = $Links
@onready var tip: Area2D = $Tip

const HOOK_STRETCH_SPEED = 12 * 60
const HOOK_RETRACT_SPEED = 20 * 60
const MAXIMUM_TIME = 0.4
const COOLDOWN_TIME = 0.0

var isStreching: bool = false
var isFixed: bool = false
var isRetracting: bool = false
var isInPocket: bool = true
var hasEntranceBonus: bool = true


var pointOfContact: Vector2 = Vector2.ZERO
var circleRadius: float = 0.0
var tipTarget: Vector2 = Vector2.ZERO
var timeSinceChange: float = 0.0

var strechingTime = 0.0

func _ready():
	pass
	tip.connect("body_entered", body_entered_hook)


func _process(delta):
	links.global_position = player.hookHand.global_position
	var hookLength = (tip.global_position - links.global_position).length() * 2
	links.region_rect = Rect2(0, 0, 16, hookLength - 4)
	links.offset.y = hookLength / 2.0
	links.rotation = (tip.global_position - player.hookHand.global_position).rotated(-PI/2).angle()
	
	if isInPocket:
		tip.global_position = player.hookHand.global_position
	elif isFixed:
		pass
	elif isRetracting:
		tip.position += (player.hookHand.global_position - tip.global_position).normalized() * HOOK_RETRACT_SPEED * delta
		if (player.hookHand.global_position - tip.global_position).length() < 3.0:
			tip.global_position = player.hookHand.global_position
			pocket()
	else: #iStreching
		tip.position += tipTarget * HOOK_STRETCH_SPEED * delta
		
		strechingTime += delta
		if strechingTime >= MAXIMUM_TIME:
			retract()

func get_new_velocity(currentVelocity: Vector2, delta) -> Vector2:
	timeSinceChange += delta
	if not isFixed:
		return currentVelocity
	
	var isInsideCircle = (tip.global_position - player.global_position).length() <= circleRadius
	
	if isInsideCircle:
		return currentVelocity
	
	if (tip.global_position - player.global_position).length() - circleRadius > 0.5:
		player.global_position = tip.global_position + (player.global_position - tip.global_position).normalized() * circleRadius

	
	var direction_to_anchor = (tip.global_position - player.global_position).normalized()

	# Calculate the swing direction based on player's position and movement
	var swing_direction = direction_to_anchor.rotated(PI / 2)
	var dot_product = currentVelocity.dot(swing_direction)
	
	if dot_product < 0:
		swing_direction = swing_direction.rotated(PI) # Reverse direction if necessary
		timeSinceChange = 0.0

		
	# Adjust speed for energy conservation
	var energy_factor = calculate_energy_factor(player.global_position, tip.global_position, circleRadius, delta)
	#var adjusted_speed = currentVelocity.length() * energy_factor * (0.7 if hasEntranceBonus else 1.0)
	var adjusted_speed: float
	if hasEntranceBonus:
		adjusted_speed = currentVelocity.project(swing_direction).length() * 1.14
	else:
		adjusted_speed = currentVelocity.project(swing_direction).length()
		#adjusted_speed = currentVelocity.length() * energy_factor
	hasEntranceBonus = false
	

	# Combine adjusted speed with new direction
	var new_velocity = swing_direction * adjusted_speed
	
	print("swing_direction = ", swing_direction)
	print("currentVelocity = ", currentVelocity.length())
	print("adjusted_speed = ", adjusted_speed)
	print("circleRadius = ", circleRadius)
	print("new_velocity.angle() = ", rad_to_deg(new_velocity.angle()) )
	
	player.get_node("velocity").rotation = new_velocity.angle()
	player.get_node("velocity").target_position.y = new_velocity.length()

	return new_velocity

func calculate_energy_factor(player_position: Vector2, anchor_point: Vector2, rope_length: float, delta: float) -> float:
	var g = 1.8 # Constant gravitational acceleration
	# Calculate height above the lowest swing point
	var height_above_lowest = (anchor_point + Vector2(0, rope_length) - player_position).y
	# Ensure the height is not negative
	height_above_lowest = max(height_above_lowest, 0)

	# Potential energy at the player's current height (PE = mgh, mass m = 1 for simplicity)
	var current_PE = g * height_above_lowest

	# Assuming the starting PE at the top is the total mechanical energy (since KE = 0 at the top)
	var total_energy_at_top = g * rope_length

	# Simulate energy loss due to friction or air resistance proportional to delta
	# This is a simplified model; adjust friction_factor to fit your game's feel
	var friction_factor = 0.01 # Energy loss factor per second
	var energy_loss = friction_factor * delta * total_energy_at_top

	# Ensure total energy is reduced by energy loss, but not below the potential energy to prevent negative KE
	var total_energy = max(total_energy_at_top - energy_loss, current_PE)

	# Current kinetic energy (KE = Total Energy - PE)
	var current_KE = total_energy - current_PE

	# Calculate current velocity magnitude from KE (KE = 0.5 * v^2, mass m = 1)
	var current_velocity_magnitude = sqrt(2 * current_KE)

	# Calculate the maximum velocity magnitude for energy at the top (all converted to KE at the lowest point)
	var max_velocity_magnitude = sqrt(2 * total_energy_at_top)

	# Calculate the energy factor as the ratio of current velocity to maximum velocity
	var energy_factor = current_velocity_magnitude / max_velocity_magnitude

	# Clamp the energy factor to prevent unrealistic values
	return 1



func body_entered_hook(body):
	if body.is_in_group("map") and isStreching:
		fixed()
		circleRadius = (player.global_position - tip.global_position).length()

func activate(direction: Vector2):
	hasEntranceBonus = true
	visible = true
	tip.look_at(direction)
	tipTarget = (direction - tip.global_position).normalized()
	isStreching = true
	isInPocket = false
	isFixed = false
	isRetracting = false
	strechingTime = 0.0

func retract():
	isStreching = false
	isFixed = false
	isInPocket = false
	isRetracting = true

func pocket():
	isStreching = false
	isFixed = false
	isRetracting = false
	isInPocket = true
	visible = false
	strechingTime = 0.0
	player.isSwinging = true

func fixed():
	isStreching = false
	isRetracting = false
	isInPocket = false
	isFixed = true

func _input(event):
	if event.is_action_pressed("hook") and isInPocket == true:
		var mousePosition = get_global_mouse_position()
		activate(mousePosition)
	if event.is_action_released("hook"):
		if isFixed:
			player.velocity.x *= 2
			player.velocity.y *= 1.5
		retract()
