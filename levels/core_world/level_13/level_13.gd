extends Node2D

@export var player: Player

func _on_default_game_master_fade_out_player_death():
	get_node("/root/GameManager").fade_out()
	get_node("/root/GameManager").increment_death()

func _on_default_game_master_fade_in_player_respawn():
	get_node("/root/GameManager").fade_in()

func _on_default_door_player_passed_level():
	player.take_controllers_away()
	player.process_mode = Node.PROCESS_MODE_DISABLED
	get_node("/root/GameManager").load_next_level(get_tree().current_scene.scene_file_path)

func _physics_process(delta):
	player.velocity.x += 3
