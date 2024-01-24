extends CanvasLayer
class_name GameManagerClass
signal fade_out_complete

@export var textureRect: TextureRect
@onready var gameVariables : GameVariablesClass = get_node("/root/GameVariables")

#SIGNALS
signal show_UI
signal hide_UI

#TRANSITION STATS
var isFadingIn: bool = false
var isFadingOut: bool = false
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
	
	totalNumberOfDeaths += currentNumberOfDeaths
	currentNumberOfDeaths = 0

	var scenePosition = coreWorld.find(currentScene)
	levelsCleared[scenePosition] = true
	save_file()
	var nextScene = load(coreWorld[scenePosition + 1])
	get_tree().change_scene_to_packed(nextScene)
	fade_in()

func load_level(levelToLoad: String) -> void:
	var level = load(levelToLoad)
	get_tree().change_scene_to_packed(level)

func increment_death():
	currentNumberOfDeaths += 1


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
		gameVariables.canPlayerMove = node_data["canPlayerMove"]
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
		"canPlayerMove" : gameVariables.canPlayerMove,
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
		show_UI.emit()		

func isInGame() -> bool:
	var currentName = get_tree().current_scene.scene_file_path
	for world in coreWorld:
		if currentName in world:
			return true
	return false
