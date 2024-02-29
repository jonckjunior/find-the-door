extends RichTextLabel

@onready var gameManager: GameManagerClass = get_node("/root/GameManager")

var textWithoutBBCode = ""
var waitTime = 0.05


func _ready():
	#gameManager.visible = false
	await get_tree().create_timer(5).timeout
	text = "DEVELOPED BY: BRUTE STUDIOS\nYOUR BEST TIME WAS [rainbow]" + str(get_time()) + "[/rainbow] \nAND YOU COLLECTED [rainbow]" + get_coins() +  "[/rainbow] COINS \n [shake]THANK YOU FOR PLAYING![/shake]"
	$Timer.start()
	textWithoutBBCode = remove_bbcode(text)
	visible_ratio = 0.0
	$Timer.wait_time = waitTime
	
func remove_bbcode(txt: String) -> String:
	var regex = RegEx.new()
	regex.compile("\\[\\/?.+?\\]")  # Regular expression for BBCode tags
	return regex.sub(txt, "", true)  # Replace BBCode tags with empty string

func _on_timer_timeout():
	if visible_ratio == 1.0:
		return
	if (textWithoutBBCode[visible_characters] != ' '):
		$AudioStreamPlayer2D.play()
	visible_characters += 1

func reset():
	textWithoutBBCode = remove_bbcode(text)
	visible_ratio = 0.0
	visible_characters = 0
	$Timer.stop()
	$Timer.wait_time = waitTime
	$Timer.start()

func get_coins():
	var total = gameManager.coinsCleared.size()
	var collected = 0
	for coin in gameManager.coinsCleared:
		if coin:
			collected += 1
	
	return str(collected) + "/" + str(total)

func get_time():
	var totalSeconds = int((get_node("/root/GameManager") as GameManagerClass).runTime)
	var seconds = totalSeconds % 60
	var minutes = (totalSeconds / 60) % 60
	var hours = (totalSeconds / 3600) % 24
	var time_string = "%02d:%02d:%02d" % [hours, minutes, seconds]
	return time_string
