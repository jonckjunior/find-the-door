extends RichTextLabel

var textWithoutBBCode = ""
var waitTime = 0.05

func _ready():
	var gameManager = get_node("/root/GameManager")
	gameManager.visible = false
	text += "  " + str(get_time())
	$Timer.start()
	textWithoutBBCode = remove_bbcode(text)
	visible_ratio = 0.0
	$Timer.wait_time = waitTime
	
func remove_bbcode(txt: String) -> String:
	var regex = RegEx.new()
	regex.compile("\\[\\/?.+?\\]")  # Regular expression for BBCode tags
	return regex.sub(txt, "", true)  # Replace BBCode tags with empty string

func _on_timer_timeout():
	if visible_ratio == 1.0:
		return
	if (textWithoutBBCode[visible_characters] != ' '):
		$AudioStreamPlayer2D.play()
	visible_characters += 1

func reset():
	textWithoutBBCode = remove_bbcode(text)
	visible_ratio = 0.0
	visible_characters = 0
	$Timer.stop()
	$Timer.wait_time = waitTime
	$Timer.start()

func get_time():
	var totalSeconds = int((get_node("/root/GameManager") as GameManagerClass).runTime)
	var seconds = totalSeconds % 60
	var minutes = (totalSeconds / 60) % 60
	var hours = (totalSeconds / 3600) % 24
	var time_string = "%02d:%02d:%02d" % [hours, minutes, seconds]
	return time_string
