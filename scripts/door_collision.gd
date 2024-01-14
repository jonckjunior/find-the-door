extends CollisionShape2D

@export var upKeyButton: Sprite2D
var time: float = 0
var activated: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	upKeyButton.modulate.a = 0

func _process(delta):
	if activated:
		time += delta * 2
		upKeyButton.modulate.a = (sin(time) + 1) / 2
