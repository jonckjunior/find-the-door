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

func get_new_velocity(currentVelocity: Vector2) -> Vector2:
	if not isFixed:
		return currentVelocity
	
	var isInsideCircle = (tip.global_position - player.hookHand.global_position).length() <= circleRadius
	
	if isInsideCircle:
		return currentVelocity
	
	#var H = tip.global_position - player.hookHand.global_position
	#var N = H.rotated(PI/2) if currentVelocity.x >= 0 else H.rotated(-PI/2)
	#var V = currentVelocity
	#var newV = N.normalized() * V.length() * (1.4 if hasEntranceBonus else 1.0)
	#
	#print("V normalizado em N = ", V.project(N).normalized() )
	#print("H = ", H)
	#print("N = ", N)
	#print("V = ", V)
	#print("newV = ", newV)
	#hasEntranceBonus = false
#
	#return newV
	
	var direction_to_anchor = (tip.global_position - player.global_position).normalized()

	# Calculate the swing direction based on player's position and movement
	var swing_direction = direction_to_anchor.rotated(PI / 2)
	if currentVelocity.dot(swing_direction) < 0:
		swing_direction = swing_direction.rotated(PI) # Reverse direction if necessary

	# Adjust speed for energy conservation
	var energy_factor = calculate_energy_factor(player.global_position, tip.global_position, circleRadius)
	var adjusted_speed = currentVelocity.length() * energy_factor * (1.4 if hasEntranceBonus else 1.0)
	hasEntranceBonus = false

	# Combine adjusted speed with new direction
	var new_velocity = swing_direction * adjusted_speed

	return new_velocity

func calculate_energy_factor(player_position: Vector2, anchor_point: Vector2, rope_length: float) -> float:
	# Calculate the lowest point of the swing
	var lowest_point = anchor_point + Vector2(0, rope_length)
	
	# Calculate the player's current height relative to the lowest point
	var height_relative_to_lowest = lowest_point.y - player_position.y
	
	# Assuming the swing starts at the highest point (rope_length vertical distance from lowest point)
	# Normalize height to a range of [0, 1] where 0 is the lowest point and 1 is the highest
	var normalized_height = clamp(height_relative_to_lowest / rope_length, 0.0, 1.0)
	
	# Convert normalized height into an energy factor
	# This could be a simple linear conversion or something more complex to simulate energy conservation
	# For a basic implementation, let's assume speed increases towards the bottom and decreases towards the top linearly
	var energy_factor = 1.0 - normalized_height # Inverts the relationship (more speed at lower heights)
	
	# Adjust the factor to ensure it scales the speed appropriately
	# You might want to scale this factor based on testing to get the desired gameplay feel
	# For example, ensuring that the player doesn't slow down too much or speed up too excessively
	energy_factor = lerp(0.8, 1.2, energy_factor) # Example adjustment, tweak as necessary
	
	return 1

func body_entered_hook(body):
	if body.is_in_group("map") and isStreching:
		fixed()
		circleRadius = (player.hookHand.global_position - tip.global_position).length()

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

func fixed():
	isStreching = false
	isRetracting = false
	isInPocket = false
	isFixed = true
	player.velocity *= 0.7

func _input(event):
	if event.is_action_pressed("hook") and isInPocket == true:
		var mousePosition = get_global_mouse_position()
		activate(mousePosition)
	if event.is_action_released("hook"):
		if isFixed:
			player.velocity.x *= 2
			player.velocity.y *= 1.5
		retract()
