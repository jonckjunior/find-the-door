extends Area2D

@export var typewritter: RichTextLabel
var activated: bool = false


func _on_body_entered(body):
	if body.is_in_group("player") and not activated:
		typewritter.reset("ENTER THE DOOR")
