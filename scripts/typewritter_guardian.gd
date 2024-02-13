extends RichTextLabel

@onready var gameManager: GameManagerClass = get_node("/root/GameManager")
var textWithoutBBCode = ""
var waitTime = 0.08
var isCurrentTextFinished: bool = false

signal show_next_dialogue
signal show_next_dialogue_button

func _ready():
	$AudioStreamPlayer2D.pitch_scale = 0.3

func show_dialogue(txt: String):
	isCurrentTextFinished = false
	text = txt.to_upper()
	reset()

func _process(_delta):
	if visible_ratio == 1.0:
		isCurrentTextFinished = true
		show_next_dialogue_button.emit()
	
	if Input.is_action_pressed("jump") and isCurrentTextFinished:
		show_next_dialogue.emit()

func remove_bbcode(txt: String) -> String:
	var regex = RegEx.new()
	regex.compile("\\[\\/?.+?\\]")
	return regex.sub(txt, "", true)

func _on_timer_timeout():
	if visible_ratio == 1.0:
		return
	if (textWithoutBBCode[visible_characters - 1] != ' '):
		$AudioStreamPlayer2D.play()
	
	visible_characters = min(visible_characters + 2, textWithoutBBCode.length())

func reset():
	textWithoutBBCode = remove_bbcode(text)
	visible_ratio = 0.0
	visible_characters = 0
	$Timer.stop()
	$Timer.wait_time = waitTime
	$Timer.start()
