extends Button

var baseText: String
var levelToLoad: String

func _ready():
	baseText = text
	text = "  "
	$RichTextLabel.text = baseText

	if get_node("/root/GameManager").is_level_available(levelToLoad):
		unlock_level()
	else:
		lock_level()

func _on_focus_entered():
	$RichTextLabel.text = "[shake rate=20.0 level=8 connected=1]" + baseText

func _on_focus_exited():
	$RichTextLabel.text = baseText

func _on_pressed():
	var effects = get_node("/root/MainMenuEffects")
	if effects.isFadingIn || effects.isFadingOut: return
	var gameManager = get_node("/root/GameManager")
	var lodadedLevel = load(levelToLoad)
	await effects.transition(get_parent(), lodadedLevel)

func refresh():
	_ready()

func unlock_level():
	disabled = false
	visible = true

func lock_level():
	disabled = true
	visible = false
