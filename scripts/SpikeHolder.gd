extends Node2D

func _ready():
	for child in get_children():
		if "kill_player" in child.get_signal_list():
			child.connect("kill_player")
