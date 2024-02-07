extends Area2D

@onready var parent: LevelManager = get_parent().get_parent()

func _ready():
	connect("body_entered", parent._on_Area2D_body_entered)
