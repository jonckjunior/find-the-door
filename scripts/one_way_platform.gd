extends Sprite2D

@onready var collision: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var marker: Marker2D = $Marker2D
var target: Player = null

func _process(delta):
	if target == null:
		var playerNode = get_parent().get_node("Player")
		if playerNode != null:
			target = playerNode
	else:
		var targetPosition = target.get_node("OneWayMarker").global_position
		if marker.global_position.y < targetPosition.y:
			collision.set_deferred("disabled", true)
		else:
			collision.set_deferred("disabled", false)
