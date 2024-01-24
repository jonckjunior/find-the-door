extends RichTextLabel

var baseText: String
var levelToLoad: String

func _ready():
	baseText = text
	$LoadLevelButton.text = baseText

func _on_focus_entered():
	text = "[shake rate=20.0 level=8 connected=1]" + baseText

func _on_focus_exited():
	text = baseText

func _on_pressed():
	get_node("/root/GameManager").load_level(levelToLoad)

func refresh():
	_ready()
	position = $LoadLevelButton.position
