extends Node

var Party = []
var Enemies = []

var possible_attack
var possible_attacker
var possible_target

@onready var Positions = {
	"party": [
		$Party_Second_Position,
		$Party_First_Position,
		$Party_Third_Position,
		$Party_Fourth_Position
	],
	"enemy": [
		$Enemy_Second_Position,
		$Enemy_First_Position,
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
		Party[index].ready_to_attack.connect(_on_entity_ready_to_attack)
		Party[index].attacking.connect(_on_attacking_entity)
		Party[index].lock()
		add_child(Party[index])	
		
	for index in range(len(enemies)):
		var temp_load = load("res://Scenes/Actors/Enemy.tscn")
		Enemies.append(temp_load.instantiate())
		Enemies[index].position = Positions.enemy[index].position
		Enemies[index].load_data(enemies[index])
		Enemies[index].being_attacked.connect(_on_entity_being_attacked)
		add_child(Enemies[index])
	
	#player = temp_load
	#player.position = $Marker2D4.position
	#add_child(player)

func _on_entity_ready_to_attack(attack, attacker):
	possible_attack = attack
	possible_attacker = attacker
	for e in Enemies:
		e.attack_danger = true
		
func _on_entity_being_attacked(entity):
	for e in Enemies:
		e.attack_danger = false
	possible_attacker.start_attack(possible_attack)
	possible_target = entity
	
func _on_attacking_entity(attack):
	possible_target.get_dmg(attack)
