extends Node
class_name Dialogues

var dialogues_guardian: Array
var dialogues_traveler: Array

func _ready():
	for i in range(100):
		dialogues_guardian.append([])
		dialogues_traveler.append([])
	
	fill_dialogues()

func fill_dialogues():
	
	dialogues_traveler[0].append("Hey there! Zezinho at your service, [font_size=12]or disservice[/font_size], depending on how you view unsolicited advice!")
	dialogues_traveler[0].append("You're about to dive headfirst into a world where even shadows hesitate to tread.")
	dialogues_traveler[0].append("But fear not! I've braved these trials... [font_size=12]from a very safe distance.[/font_size]")
	dialogues_traveler[0].append("Expect [wave]twists[/wave], [tornado]turns[/tornado], and the occasional [shake]existential crisis.[/shake]")
	dialogues_traveler[0].append("Oh, and if you find my lost socks in the abyss, [rainbow]do return them![/rainbow]")
	
	dialogues_guardian[0].append("BY ANCIENT LAW, I AM COMPELLED TO GRANT YOU PASSAGE INTO THESE HALLS OF TRIAL. BUT MAKE NO MISTAKE, YOUR WELCOME ENDS HERE.\n\nTHE PATH YOU EMBARK UPON HAS BEEN TREADED BY COUNTLESS BEFORE YOU—BOLDER, WISER, YET ALL MET WITH FAILURE.")
	dialogues_guardian[0].append("PERHAPS YOU BELIEVE YOUR FATE TO BE DIFFERENT, BUT THE GROUNDS AHEAD CARE LITTLE FOR BELIEF.\n\nPROCEED, WITH THE WEIGHT OF HISTORY AGAINST YOU.")
	
	
	dialogues_guardian[1].append("YOU SURVIVED THE FIRST CHALLENGE. RELUCTANTLY, FATE BINDS ME TO EMPOWER YOU WITH SURGE.\n\nPRESS 'Z' OR 'SHIFT' TO HARNESS ITS FORCE, A GIFT I DISPENSE WITH CAUTION.")
	dialogues_guardian[1].append("THIS REALM'S PEAKS DERIDE THE BOLD, THE FALLS AWAIT THE EAGER.\n\nWITH A WATCHFUL EYE, I AWAIT: WILL YOU ASCEND OR JOIN THE SHADOWS? PROCEED, IF YOU DARE.")
	
	#dialogues_traveler[2].append("Ah, there you are, zigzagging through puzzles like a river carving its path.")
	#dialogues_traveler[2].append("Ever feel like the Guardian's gaze is a bit too... [shake]intense[/shake]? As if he's hoping you'll trip on your own feet?")
	#dialogues_traveler[2].append("Well, joke's on him! Life's a [wave]spiral[/wave] staircase – you think you're going up, but really, you're just [tornado]circling[/tornado] sideways.")
	#dialogues_traveler[2].append("Keep that in mind, and you might just outmaneuver his expectations.")

	dialogues_traveler[5].append("You're making [wave]waves[/wave], my friend! Even the stoic Guardian seems a tad more... [rainbow]animated[/rainbow] these days.")
	dialogues_traveler[5].append("And because I'm all for stirring the pot, I've brought you a [font_size=12]little something[/font_size] to spice things up – a [shake]grappling hook![/shake]")
	dialogues_traveler[5].append("Why, you ask? Let's just say it's my way of adding a bit of zest to the Guardian's watchful routine.")
	dialogues_traveler[5].append("Aim well, swing boldly, and let's carve a path that'll leave him scratching his head!")
	
	dialogues_guardian[5].append("A [shake]GRAPPLING HOOK[/shake], COURTESY OF ZEZINHO, NOW LIES WITHIN YOUR REACH.\n\nHIS ACTIONS, AS EVER, ARE LAYERED WITH MEANING, SUGGESTING A DEEPER FAITH IN YOUR POTENTIAL THAN EVEN YOU MAY HARBOUR.")
	dialogues_guardian[5].append("NAVIGATE THIS GIFT WITH CARE; ITS CAPACITY TO ALTER YOUR PATH IS IMMENSE.\n\nONE MUST WONDER, WHAT DOES ZEZINHO SEE IN YOU THAT PROMPTED SUCH A BOON?")
