extends Sprite2D
var total_time: float = 0.0
var displacement: float = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	total_time += delta * 3
	position.y -= displacement * 2
	displacement = sin(total_time)
	position.y += displacement * 2
