extends CanvasLayer
class_name GameManagerClass

signal fade_out_complete
signal fade_in_complete
signal new_scene_loaded

@export var textureRect: TextureRect
@onready var gameVariables : GameVariablesClass = get_node("/root/GameVariables")
@onready var rect : ColorRect = $ColorRect

#TRANSITION STATS
var isFadingIn: bool = false
var isFadingOut: bool = false
var isFadingInMainMenu: bool = false
var isFadingOutMainMenu: bool = false
var transitionProgress : float = 0.0

# PLAYER STATS
var totalNumberOfDeaths : int = 0
var currentNumberOfDeaths : int = 0
var runTime: float = 0.0

# WORLS STATS
var coreWorld = []
var levelsCleared = []

var currentScene : String = ""

func _ready():
	for x in range(14):
		coreWorld.append("res://levels/core_world/level_" + str(x) + "/level_" + str(x) + ".tscn")
	coreWorld.append("res://levels/core_world/end_game/level_end_game.tscn")
	load_save_file()
	
func fade_in():
	transitionProgress = 1.0
	isFadingIn = true

func fade_out():
	transitionProgress = 0.0
	isFadingOut = true

func _process(delta):
	update_time(delta)
	
	if isFadingInMainMenu:
		fade_in_main_menu(delta)
	elif isFadingOutMainMenu:
		fade_out_main_menu(delta)

	if isFadingIn:
		transitionProgress = max(transitionProgress - delta * 4.0, 0.0)
		if transitionProgress == 0.0:
			isFadingIn = false
			fade_in_complete.emit()
		(textureRect.material as ShaderMaterial).set_shader_parameter("progress", transitionProgress)
	elif isFadingOut:
		transitionProgress = min(transitionProgress + delta * 4.0, 1.0)
		if transitionProgress == 1.0:
			isFadingOut = false
			fade_out_complete.emit()
		(textureRect.material as ShaderMaterial).set_shader_parameter("progress", transitionProgress)

func load_next_level(currentScene: String) -> void:
	var scenePosition = coreWorld.find(currentScene)
	var nextScene = load(coreWorld[scenePosition + 1])
	
	fade_out()
	$AudioDoorUse.play()
	
	totalNumberOfDeaths += currentNumberOfDeaths
	currentNumberOfDeaths = 0
	
	levelsCleared[scenePosition] = true
	save_file()
	
	gameVariables.canPlayerMove = false
	
	var screenDimension = Vector2(160, 93)#get_viewport().get_visible_rect().size / 2
	var oldCamera = get_tree().current_scene.camera
	var oldPlayer = get_tree().current_scene.player
	var playerPositionFrom = oldPlayer.global_position - oldCamera.get_screen_center_position() + screenDimension
	
	$UI/CharacterTransition.scale = oldPlayer.get_node("AnimatedSprite2D").scale
	$UI/CharacterTransition.global_position = playerPositionFrom
	$UI/CharacterTransition.visible = true
	
	await fade_out_complete
	
	get_tree().change_scene_to_packed(nextScene)
	
	await new_scene_loaded
	
	var instantiatedScene = get_tree().current_scene
	#instantiatedScene.camera.global_position = instantiatedScene.player.global_position
	print((instantiatedScene.camera as Camera2D).get_screen_center_position())
	print(instantiatedScene.camera.global_position)
	var playerPositionTo = instantiatedScene.player.global_position - (instantiatedScene.camera as Camera2D).get_screen_center_position() + screenDimension - Vector2(0, 0.5)

	get_tree().create_tween().tween_property($UI/CharacterTransition, "scale", instantiatedScene.player.scale, 1.5).set_trans(Tween.TRANS_EXPO).finished
	await get_tree().create_tween().tween_property($UI/CharacterTransition, "global_position", playerPositionTo, 1.5).set_trans(Tween.TRANS_EXPO).finished
	
	fade_in()
	await fade_in_complete
	$UI/CharacterTransition.visible = false
	gameVariables.canPlayerMove = true
	get_tree().current_scene.player.canPlayerMove = true

func load_level(levelToLoad: String) -> void:
	var level = load(levelToLoad)
	get_tree().change_scene_to_packed(level)

func increment_death():
	currentNumberOfDeaths += 1
	save_file()

func load_save_file():
	if not FileAccess.file_exists("user://savegame.save"):
		for world in coreWorld:
			levelsCleared.append(false)
		return # Error! We don't have a save to load.

	var save_game = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_game.get_position() < save_game.get_length():
		var json_string = save_game.get_line()
		var json = JSON.new()

		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		var node_data = json.get_data()
		print(node_data)
		levelsCleared = node_data["levelsCleared"]
		totalNumberOfDeaths = node_data["numberOfDeaths"]
		gameVariables.dashUnlocked = node_data["dashUnlocked"]
		gameVariables.wallSlideUnlocked = node_data["wallSlideUnlocked"]
		gameVariables.wallJumpUnlocked = node_data["wallJumpUnlocked"]
		gameVariables.isJumpUnlocked = node_data["isJumpUnlocked"]
		runTime = node_data["runTime"]

func save_file():
	var save_game = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var json_string = JSON.stringify(get_save_data())
	save_game.store_line(json_string)
	print(json_string)


func is_level_available(level: String) -> bool:
	var position = coreWorld.find(level)
	var levelIsCleared = position != -1 && levelsCleared[position]
	var previousLevelWasCleared = position >= 0 && (levelsCleared[position - 1] || position == 0)
	return levelIsCleared || previousLevelWasCleared

func transition_to_packed(packedScene: PackedScene):
	get_tree().change_scene_to_packed(packedScene)

func get_save_data() -> Dictionary:
	return {
		"levelsCleared" : levelsCleared,
		"numberOfDeaths" : totalNumberOfDeaths,
		"dashUnlocked" : gameVariables.dashUnlocked,
		"wallSlideUnlocked" : gameVariables.wallSlideUnlocked,
		"wallJumpUnlocked" : gameVariables.wallJumpUnlocked,
		"isJumpUnlocked" : gameVariables.isJumpUnlocked,
		"runTime" : runTime
	}

func update_time(delta):
	if get_tree().current_scene == null:
		return
	# todo(jonck): otimizar isso
	if isInGame():
		runTime += delta
		$UI.visible = true

func isInGame() -> bool:
	var currentName = get_tree().current_scene.scene_file_path
	for world in coreWorld:
		if currentName in world:
			return true
	return false


func fade_in_main_menu(delta):
	var shaderMaterial = rect.material as ShaderMaterial
	var currentValue = shaderMaterial.get_shader_parameter("static_noise_intensity")
	var newValue = max(0.06, currentValue - delta)
	shaderMaterial.set_shader_parameter("static_noise_intensity", newValue)
	
	if newValue == 0.06:
		isFadingInMainMenu = false

func fade_out_main_menu(delta):
	var shaderMaterial = rect.material as ShaderMaterial
	var currentValue = shaderMaterial.get_shader_parameter("static_noise_intensity")
	var newValue = min(1.0, currentValue + delta)
	shaderMaterial.set_shader_parameter("static_noise_intensity", newValue)
	
	if newValue == 1.0:
		isFadingOutMainMenu = false

func transition_main_menu(fromObject: Object, sceneToTransitionTo: PackedScene):
	if isFadingInMainMenu || isFadingOutMainMenu:
		return

	isFadingOutMainMenu = true
	await get_tree().create_tween().tween_property(fromObject, "modulate:a", 0.0, 1.0).finished
	isFadingInMainMenu = true
	transition_to_packed(sceneToTransitionTo)

func get_player_position_for_scene(camera: Camera2D, player: Player) -> Vector2:
	var camera_screen_center = camera.get_screen_center_position()
	print("camera_screen_center = ", camera_screen_center, camera.position, player.position)
	var node_global_position = player.global_position
	var relative_position = node_global_position - camera_screen_center
	return relative_position
