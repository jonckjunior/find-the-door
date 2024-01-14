extends Sprite2D
var fade_out_duration = 0.5

func _ready():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0, fade_out_duration)
