extends Node

var runTime: float
var numberOfDeaths: int

func _ready():
	runTime = 0.0
	numberOfDeaths = 0

func _process(delta):
	runTime += delta
