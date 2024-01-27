extends Button

var baseText: String

func _ready():
	baseText = text
	text = "          "
	$RichTextLabel.text = "[shake rate=4.0 level=3 connected=1]" + baseText

func _on_focus_entered():
	$RichTextLabel.text = "[shake rate=20.0 level=8 connected=1]" + baseText

func _on_focus_exited():
	$RichTextLabel.text = "[shake rate=4.0 level=3 connected=1]" + baseText
