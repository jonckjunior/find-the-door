extends Node2D

@export var textureRect: TextureRect
@export var player: Player
var transitionProgress = 0.0
var isFadingIn: bool = false
var isFadingOut: bool = false

func _ready():
	fade_in()

func fade_in():
	transitionProgress = 1.0
	isFadingIn = true

func fade_out():
	transitionProgress = 0.0
	isFadingOut = true

func _process(delta):
	if isFadingIn:
		transitionProgress = max(transitionProgress - delta * 1.7, 0.0)
		if transitionProgress == 0.0:
			isFadingIn = false
	elif isFadingOut:
		transitionProgress = min(transitionProgress + delta * 1.7, 1.0)
		if transitionProgress == 1.0:
			isFadingOut = false

	(textureRect.material as ShaderMaterial).set_shader_parameter("progress", transitionProgress)

func _on_default_game_master_fade_out_player_death():
	fade_out()

func _on_default_game_master_fade_in_player_respawn():
	fade_in()
