extends RichTextLabel

@onready var gameManager : GameManagerClass = get_node("/root/GameManager")
var runTime: float = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	runTime = gameManager.runTime
	var totalSeconds = int(runTime)
	var seconds = totalSeconds % 60
	var minutes = (totalSeconds / 60) % 60
	var hours = (totalSeconds / 3600) % 24
	var time_string = "TIME %02d:%02d:%02d" % [hours, minutes, seconds]
	text = time_string
