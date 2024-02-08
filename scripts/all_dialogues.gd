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
	dialogues_traveler[8].append("Hello, boy!")
	dialogues_traveler[8].append("It's a me, Zezin!")
