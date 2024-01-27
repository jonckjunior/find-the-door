extends Node2D

@export var player: Player
@export var camera: Camera2D
@export var typewritter: RichTextLabel
@export var respawnPosition: Vector2
@onready var gameManager: GameManagerClass = get_node("/root/GameManager")

func _ready():
	respawnPosition = player.global_position
	configure_player_killer()
	configure_camera()
	configure_map()
	camera.global_position = player.global_position

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
	
	var rect = Rect2()
	var foundCamera: bool = false
	
	for child in $map.get_children():
		if child.name == "camera_limits":
			foundCamera = true
			var area = child.get_child(0)
			assert(area is Area2D)
			var collisionShape = area.get_child(0)
			assert(collisionShape is CollisionShape2D)
			
			camera.global_position = area.global_position
			var shape_extents = collisionShape.shape.extents
			rect = Rect2(camera.global_position, shape_extents * 2)

	if !foundCamera:
		return

	camera.limit_left = rect.position.x
	camera.limit_top = rect.position.y
	camera.limit_right = rect.end.x
	camera.limit_bottom = rect.end.y

func _on_Area2D_body_entered(body):
	if body.is_in_group("player") and not body.isDying:
		body.die()
