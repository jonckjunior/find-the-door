extends RichTextLabel

var activated: bool = false
var currentDeath: int = -5
var totalDeath: int = -5
@onready var gameManager: GameManagerClass = get_node("/root/GameManager")
@export var spriteDeathCounter: Sprite2D

func _ready():
	gameManager.show_UI.connect(activate)
	gameManager.hide_UI.connect(deactivate)

func _process(delta):
	currentDeath = gameManager.currentNumberOfDeaths
	totalDeath = gameManager.totalNumberOfDeaths
	text = str(currentDeath) + "/" + str(currentDeath + totalDeath)	

func activate():
	visible = true
	spriteDeathCounter.visible = true

func deactivate():
	visible = false
	spriteDeathCounter.visible = false
