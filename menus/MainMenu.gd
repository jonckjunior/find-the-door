extends Control

@onready var effects = get_node("/root/MainMenuEffects")
@onready var loadedLevelChooser = preload("res://menus/LevelChooser.tscn")
@export var playButton: Button
@export var optionsButton: Button
@export var quitButton: Button

func _ready():
	effects.activate()
	effects.isFadingIn = true
	modulate.a = 0.0
	get_tree().create_tween().tween_property(self, "modulate:a", 1.0, 1.0)
	
	playButton.pressed.connect(playButtonPressed)
	optionsButton.pressed.connect(optionsButtonPressed)
	quitButton.pressed.connect(quitButtonPressed)

	playButton.grab_focus()

func playButtonPressed():
	await effects.transition(self, loadedLevelChooser)

func optionsButtonPressed():
	pass

func quitButtonPressed():
	get_tree().quit()
