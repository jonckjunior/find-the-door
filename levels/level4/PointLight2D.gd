extends PointLight2D

var target = null

func _ready():
	target = get_parent().get_node("Player")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target != null and target.visible == true:
		global_position = target.global_position
