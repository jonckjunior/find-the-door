extends Node2D

@onready var resumeButton: Button = $VBoxContainer/ResumeButton
@onready var restartButton: Button = $VBoxContainer/RestartButton
@onready var mainMenuButton: Button = $VBoxContainer/MainMenuButton
@onready var quitButton: Button = $VBoxContainer/QuitButton
@onready var buttons = [resumeButton, restartButton, mainMenuButton, quitButton]
@onready var gameManager: GameManagerClass = get_node("/root/GameManager")
var isPaused : bool = false


func _ready():
	for button in buttons:
		button.process_mode = PROCESS_MODE_ALWAYS
	
	resumeButton.pressed.connect(resumeButtonPressed)
	restartButton.pressed.connect(restartButtonPressed)
	mainMenuButton.pressed.connect(mainMenuButtonPressed)
	quitButton.pressed.connect(quitButtonPressed)

	resumeButton.grab_focus()
	resumeGame()
	

func resumeButtonPressed():
	resumeGame()

func restartButtonPressed():
	get_tree().current_scene.player.die()
	resumeGame()

func mainMenuButtonPressed():
	pass

func quitButtonPressed():
	get_tree().quit()

func _input(event):
	if event.is_action_pressed("pause") and gameManager.isInGame():
		if isPaused:
			resumeGame()
		else:
			pauseGame()

func resumeGame():
	visible = false
	isPaused = false

	get_tree().paused = false

func pauseGame():
	isPaused = true
	visible = true
	
	resumeButton.grab_focus()
	
	get_tree().paused = true
