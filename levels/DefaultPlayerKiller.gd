extends Area2D

signal kill_player

func _ready():
	for child in get_children():
		if child.has_signal("kill_player"):
			child.connect("kill_player", _on_child_kill_player)

func _on_child_kill_player():
	kill_player.emit()

func _on_body_entered(body):
	if body.is_in_group("player") and body.isDying == false:
		kill_player.emit()
