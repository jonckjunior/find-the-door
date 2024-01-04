extends Camera2D
@export var target: CharacterBody2D
@export var randomStrength: float = 2
@export var shakeFade: float = 10

var rng = RandomNumberGenerator.new()
var shakeStrength: float = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target != null:
		position = target.position
	
	if shakeStrength > 0.0:
		shakeStrength = lerp(shakeStrength, 0.0, shakeFade * delta)
		offset = randomOffset()

func apply_shake():
	shakeStrength = randomStrength
	
func randomOffset() -> Vector2:
	return Vector2(rng.randf_range(-shakeStrength, shakeStrength), rng.randf_range(-shakeStrength, shakeStrength))
