extends Node

var Party = []
var Enemies = []

@onready var Positions = {
	"party": [
		$Party_Second_Position,
		$Party_First_Position,
		$Party_Third_Position,
		$Party_Fourth_Position
	],
	"enemy": [
		$Enemy_First_Position,
		$Enemy_Second_Position,
		$Enemy_Third_Position,
		$Enemy_Fourth_Position
	]
}


func _ready():
	pass


func _process(delta):
	pass
	
func load_entities(party, enemies):
	for index in range(len(party)):
		var temp_load = load(party[index])
		Party.append(temp_load.instantiate())
		Party[index].position = Positions.party[index].position
		add_child(Party[index])	
		
	for index in range(len(enemies)):
		var temp_load = load("res://Scenes/Actors/Enemy.tscn")
		Enemies.append(temp_load.instantiate())
		Enemies[index].position = Positions.enemy[index].position
		Enemies[index].load_data(enemies[index])
		add_child(Enemies[index])
	
	#player = temp_load
	#player.position = $Marker2D4.position
	#add_child(player)
