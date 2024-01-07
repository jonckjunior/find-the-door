extends RichTextLabel

var textWithoutBBCode = ""
var isImageThere: bool = false
var alreadyReset: bool = false
@export var imageToShow: Sprite2D

func _ready():
	$Timer.start()
	textWithoutBBCode = remove_bbcode(text)
	imageToShow.visible = false
	visible_ratio = 0.0
	
func remove_bbcode(txt: String) -> String:
	var regex = RegEx.new()
	regex.compile("\\[\\/?.+?\\]")  # Regular expression for BBCode tags
	return regex.sub(txt, "", true)  # Replace BBCode tags with empty string

func _on_timer_timeout():
	if visible_ratio == 1.0:
		if not isImageThere:
			$AudioStreamPlayer2D.play()
			isImageThere = true
			imageToShow.visible = true
		return
	if (textWithoutBBCode[visible_characters] != ' '):
		$AudioStreamPlayer2D.play()
	visible_characters += 1

func reset(txt):
	if alreadyReset:
		return
	alreadyReset = true
	text = txt
	visible_ratio = 0.0
	visible_characters = 0
	imageToShow.visible = false
	textWithoutBBCode = remove_bbcode(text)
