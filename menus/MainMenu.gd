extends Control

@onready var gameManager = get_node("/root/GameManager")
@onready var loadedLevelChooser = preload("res://menus/LevelChooser.tscn")
@export var playButton: Button
@export var optionsButton: Button
@export var quitButton: Button

func _ready():
	gameManager.isFadingInMainMenu = true
	modulate.a = 0.0
	get_tree().create_tween().tween_property(self, "modulate:a", 1.0, 1.0)
	
	playButton.pressed.connect(playButtonPressed)
	optionsButton.pressed.connect(optionsButtonPressed)
	quitButton.pressed.connect(quitButtonPressed)

	playButton.grab_focus()

func playButtonPressed():
	await gameManager.transition_main_menu(self, loadedLevelChooser, "res://menus/LevelChooser.tscn")

func optionsButtonPressed():
	pass

func quitButtonPressed():
	get_tree().quit()
