extends RichTextLabel

@onready var gameManager: GameManagerClass = get_node("/root/GameManager")

func _process(_delta):
	var coinCounter: int = 0
	for coin in gameManager.coinsCleared:
		if coin:
			coinCounter += 1
	text = "COINS " + str(coinCounter)
