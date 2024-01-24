extends Control

@onready var gameManager : GameManagerClass = get_node("/root/GameManager")
@export var rect: ColorRect
var isFadingIn: bool = false
var isFadingOut: bool = false

func _process(delta):
	if isFadingIn:
		fade_in(delta)
	elif isFadingOut:
		fade_out(delta)

func fade_in(delta):
	var shaderMaterial = rect.material as ShaderMaterial
	var currentValue = shaderMaterial.get_shader_parameter("static_noise_intensity")
	var newValue = max(0.06, currentValue - delta)
	shaderMaterial.set_shader_parameter("static_noise_intensity", newValue)
	
	if newValue == 0.06:
		isFadingIn = false

func fade_out(delta):
	var shaderMaterial = rect.material as ShaderMaterial
	var currentValue = shaderMaterial.get_shader_parameter("static_noise_intensity")
	var newValue = min(1.0, currentValue + delta)
	shaderMaterial.set_shader_parameter("static_noise_intensity", newValue)
	
	if newValue == 1.0:
		isFadingOut = false

func activate():
	$CanvasLayer/ColorRect.visible = true

func de_activate():
	$CanvasLayer/ColorRect.visible = false

func transition(fromObject: Object, sceneToTransitionTo: PackedScene):
	if isFadingIn || isFadingOut:
		return

	isFadingOut = true
	await get_tree().create_tween().tween_property(fromObject, "modulate:a", 0.0, 1.0).finished
	isFadingIn = true
	gameManager.transition_to_packed(sceneToTransitionTo)
