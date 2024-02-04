extends Node2D

@export var player: Player
@export var camera: Camera2D
@export var typewritter: RichTextLabel
@export var respawnPosition: Vector2
@onready var gameManager: GameManagerClass = get_node("/root/GameManager")

var platformsToReset : Dictionary = {}
var cameraDict : Dictionary = {}
var activatedCamera : bool = false

func _ready():
	respawnPosition = player.global_position
	configure_player_killer()
	configure_camera()
	configure_map()
	camera.global_position = player.global_position
	
	var nodesToReset = get_tree().get_nodes_in_group("reset")
	for node in nodesToReset:
		platformsToReset[node] = node.global_position

func _process(_delta):
	await get_tree().process_frame
	gameManager.new_scene_loaded.emit()

func fade_out_player_death():
	gameManager.fade_out()
	gameManager.increment_death()

func fade_in_player_respawn():
	gameManager.fade_in()

func _on_default_door_player_passed_level():
	player.take_controllers_away()
	player.process_mode = Node.PROCESS_MODE_DISABLED
	gameManager.load_next_level(get_tree().current_scene.scene_file_path)

func _on_player_player_death():
	fade_out_player_death()
	camera.death_shake()
	await get_tree().create_timer(0.5).timeout
	respawn_player()

	#await get_tree().process_frame
	#await get_tree().process_frame
	reset_platforms()

func respawn_player():
	fade_in_player_respawn()
	typewritter.reset()
	player.respawn_player(respawnPosition)

func _on_player_dash():
	camera.apply_shake()

func configure_player_killer():
	if not has_node("map"):
		return
	for player_killer in $map.get_children():
		if player_killer.name == "player_killer":
			for area in player_killer.get_children():
				assert(area is Area2D)
				if area.has_meta("type") and area.get_meta("type") == "area" and area is Area2D:
					area.connect("body_entered", _on_Area2D_body_entered)

func configure_map():
	if not has_node("map"):
		return

	for node in $map.get_children():
		if node.name == "solid_objects":
			for child in node.get_children():
				child.add_to_group("map")

func configure_camera():
	if not has_node("map"):
		return
	
	for child in $map.get_children():
		if child.name == "camera_limits":
			for area2d in child.get_children():
				assert(area2d is Area2D)
				var metaList = area2d.get_meta_list()
				if "is_camera_trigger" in metaList and "camera_number" in metaList:
					var isCameraTrigger = area2d.get_meta("is_camera_trigger")
					var cameraNumber = area2d.get_meta("camera_number")
					if isCameraTrigger == "true":
						print("ligando camera ", cameraNumber)
						(area2d as Area2D).body_entered.connect(change_camera_limits.bind(cameraNumber))
					else:
						cameraDict[cameraNumber] = area2d
				else:
					cameraDict["0"] = area2d
					(area2d as Area2D).body_entered.connect(change_camera_limits.bind("0"))

	change_camera_limits(player, "0")

func change_camera_limits(body, cameraNumber):
	var area = cameraDict[cameraNumber]
	if body.is_in_group("player"):
		camera.global_position = area.global_position
		var rect = Rect2()
		var collisionShape = area.get_child(0)
		assert(collisionShape is CollisionShape2D)
		var shape_extents = collisionShape.shape.extents
		rect = Rect2(camera.global_position, shape_extents * 2)
		
		camera.limit_left = rect.position.x
		camera.limit_top = rect.position.y
		camera.limit_right = rect.end.x
		camera.limit_bottom = rect.end.y
		#get_tree().create_tween().tween_property(camera, "limit_left", rect.position.x, 1).set_trans(Tween.TRANS_CIRC)
		#get_tree().create_tween().tween_property(camera, "limit_top", rect.position.y, 1).set_trans(Tween.TRANS_CIRC)
		#get_tree().create_tween().tween_property(camera, "limit_right", rect.end.x, 1).set_trans(Tween.TRANS_CIRC)
		#get_tree().create_tween().tween_property(camera, "limit_bottom", rect.end.y, 1).set_trans(Tween.TRANS_CIRC)
		
		var rect_width = rect.end.x - rect.position.x
		var rect_height = rect.end.y - rect.position.y
		
		var zoom_x = 320.0 / rect_width
		var zoom_y = 180.0 / rect_height
		
		var zoom_factor = max(1.0, max(zoom_x, zoom_y))
		
		camera.zoom = Vector2(zoom_factor, zoom_factor)
		#get_tree().create_tween().tween_property(camera, "zoom", Vector2(zoom_factor, zoom_factor), 0.5)

func _on_Area2D_body_entered(body):
	if body.is_in_group("player") and not body.isDying:
		body.die()

func reset_platforms():
	for node in platformsToReset:
		node.global_position = platformsToReset[node]
		node.reset()
