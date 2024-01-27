extends RichTextLabel

var activated: bool = false
var currentDeath: int = -5
var totalDeath: int = -5
@onready var gameManager: GameManagerClass = get_node("/root/GameManager")
@export var spriteDeathCounter: Sprite2D

func _process(delta):
	currentDeath = gameManager.currentNumberOfDeaths
	totalDeath = gameManager.totalNumberOfDeaths
	text = str(currentDeath) + "/" + str(currentDeath + totalDeath)	
