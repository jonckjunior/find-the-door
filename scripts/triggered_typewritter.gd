extends RichTextLabel

var textWithoutBBCode = ""
var waitTime = 0.05

func _ready():
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
	return
	textWithoutBBCode = remove_bbcode(text)
	visible_ratio = 0.0
	visible_characters = 0
	$Timer.stop()
	$Timer.wait_time = waitTime
	$Timer.start()

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		$Timer.start()
