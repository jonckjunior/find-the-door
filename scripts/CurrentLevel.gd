extends RichTextLabel

@onready var gameManager: GameManagerClass = get_node("/root/GameManager")

func _process(_delta):
	if get_parent().visible:
		var scenePosition = gameManager.get_scene_position(gameManager.currentScene)
		text = "WORLD 1-" + str(scenePosition + 1)
