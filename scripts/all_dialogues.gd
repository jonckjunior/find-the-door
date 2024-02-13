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

	
	dialogues_guardian[4].append("Reluctantly, fate decrees I grant you the Surge. \n\nWith it, press 'Z' to use its force, though it's against my better judgment.")
	dialogues_guardian[4].append("This realm's heights mock the ambitious and humiliate the eager. \n\nI watch, not with hope, but curiosity, to see if you'll soar or merely add to the shadows below. \n\nUse it, if you must.")

