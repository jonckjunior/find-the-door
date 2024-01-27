extends Sprite2D


func _ready():
	await get_tree().create_tween().tween_property(self, "position", Vector2(500, -80), 2.0).as_relative().from_current().set_trans(Tween.TRANS_BACK).finished
	print("lalal")

func _process(_delta):
	print(get_parent().get_node("Camera2D").get_screen_center_position())
