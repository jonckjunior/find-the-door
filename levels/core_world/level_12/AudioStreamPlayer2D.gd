extends AudioStreamPlayer2D

func _ready():
	play()
	var tween = get_tree().create_tween()
	tween.tween_property(self, "volume_db", -13.0, 3)

func _on_finished():
	play()
