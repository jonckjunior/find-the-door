extends CanvasLayer

signal fade_out_complete

@export var textureRect: TextureRect

var isFadingIn: bool = false
var isFadingOut: bool = false
var transitionProgress = 0.0
var totalNumberOfDeaths = 0
var currentNumberOfDeaths = 0
var coreWorld = []

func _ready():
	for x in range(14):
		coreWorld.append("res://levels/core_world/level_" + str(x) + "/level_" + str(x) + ".tscn")
	coreWorld.append("res://levels/core_world/end_game/level_end_game.tscn")

func fade_in():
	transitionProgress = 1.0
	isFadingIn = true

func fade_out():
	transitionProgress = 0.0
	isFadingOut = true

func _process(delta):
	if isFadingIn:
		transitionProgress = max(transitionProgress - delta * 4.0, 0.0)
		if transitionProgress == 0.0:
			isFadingIn = false
		(textureRect.material as ShaderMaterial).set_shader_parameter("progress", transitionProgress)
	elif isFadingOut:
		transitionProgress = min(transitionProgress + delta * 4.0, 1.0)
		if transitionProgress == 1.0:
			isFadingOut = false
			fade_out_complete.emit()
		(textureRect.material as ShaderMaterial).set_shader_parameter("progress", transitionProgress)

func load_next_level(currentScene: String) -> void:
	fade_out()
	$AudioDoorUse.play()
	await fade_out_complete
	get_tree().change_scene_to_packed(get_next_scene(currentScene))
	fade_in()

func get_next_scene(currentScene: String):
	totalNumberOfDeaths += currentNumberOfDeaths
	currentNumberOfDeaths = 0
	return load(coreWorld[coreWorld.find(currentScene) + 1])

func increment_death():
	currentNumberOfDeaths += 1
