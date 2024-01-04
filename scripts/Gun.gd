extends Sprite2D

@onready var bulletRaw = load("res://objects/bullet.tscn")
@export var muzzle : Marker2D
@onready var projectileHolder: Node2D = get_parent().get_parent().get_node("ProjectileHolder")

func _process(delta):
	look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("shoot"):
		var bullet = bulletRaw.instantiate()
		bullet.dir = Vector2(cos(rotation), sin(rotation))
		projectileHolder.add_child(bullet)
		bullet.global_transform = muzzle.global_transform
		bullet.global_position = muzzle.global_position
