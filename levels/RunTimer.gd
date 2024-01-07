extends RichTextLabel
@onready var gameVariables = get_node("/root/GameVariables")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var totalSeconds = int(gameVariables.runTime)
	var seconds = totalSeconds % 60
	var minutes = (totalSeconds / 60) % 60
	var hours = (totalSeconds / 3600) % 24
	var time_string = "TIME %02d:%02d:%02d" % [hours, minutes, seconds]
	text = time_string
