extends GridContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	var worlds = get_node("/root/GameManager").coreWorld
	var children = get_children()
	for i in children.size():
		children[i].text = str(i + 1)
		children[i].levelToLoad = "NAN" if i >= worlds.size() else worlds[i]
		children[i].refresh()
	children[0].grab_focus()
