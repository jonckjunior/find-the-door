extends TextureRect

@export var camera: Camera2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	texture = camera.get_viewport().get_texture()
