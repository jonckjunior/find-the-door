extends Node

var runTime: float
var numberOfDeaths: int
var canPlayerMove: bool = true
var dashUnlocked: bool = true
var wallSlideUnlocked: bool = true
var wallJumpUnlocked: bool = true
var isJumpUnlocked: bool = true

func _ready():
	runTime = 0.0
	numberOfDeaths = 0

func _process(delta):
	runTime += delta
