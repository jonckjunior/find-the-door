extends VBoxContainer

@export var playButton: Button
@export var optionsButton: Button
@export var quitButton: Button

func _ready():
	playButton.pressed.connect(playButtonPressed)
	optionsButton.pressed.connect(optionsButtonPressed)
	quitButton.pressed.connect(quitButtonPressed)

	playButton.grab_focus()

func playButtonPressed():
	#get_tree().change_scene_to_file("res://game_master.tscn")
	pass

func optionsButtonPressed():
	pass

func quitButtonPressed():
	get_tree().quit()
