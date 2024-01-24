extends Button

func _on_focus_entered():
	$RichTextLabel.text = "[shake rate=20.0 level=8 connected=1]QUIT"


func _on_focus_exited():
	$RichTextLabel.text = "QUIT"
