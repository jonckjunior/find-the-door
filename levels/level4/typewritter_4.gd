extends RichTextLabel

var textWithoutBBCode = ""
var player_fell: bool = false
var waitTime = 0.05

func _ready():
	$Timer.start()
	$Timer.wait_time = waitTime
	textWithoutBBCode = remove_bbcode(text)
	visible_ratio = 0.0
	
	
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
	
