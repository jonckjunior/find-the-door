extends Node2D
class_name Coin
@onready var animatedSprite = $AnimatedSprite2D
@onready var area = $Area2D
@onready var target: Player = null

var timeSum: float = 0.0

func _ready():
	if get_node("/root/GameManager").has_coin(get_tree().current_scene.scene_file_path):
		animatedSprite.material = ShaderMaterial.new()
		animatedSprite.material.shader = load("res://scripts/black_and_white_shader.gdshader")
	animatedSprite.play("default")
	area.connect("body_entered", body_entered_area)

func _process(delta):
	timeSum += delta
	position.y += sin(timeSum) * 0.01
	
	if target != null:
		global_position = lerp(global_position, target.global_position - Vector2(8, 8), delta * 2)

func body_entered_area(body):
	if body.is_in_group("player"):
		target = body
		target.coin = self

func reset():
	if target != null:
		target.coin = null
	target = null
	timeSum = 0.0
