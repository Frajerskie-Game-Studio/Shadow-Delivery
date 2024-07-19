extends Node2D

var Name
var Hp
var MaxHp
var Attack
var Skills

func _ready():
	pass

func _process(delta):
	pass

func load_data(json_path):
	var text = FileAccess.get_file_as_string(json_path)
	var temp_data = JSON.parse_string(text)
	Name = temp_data["name"]
	Hp = temp_data["hp"]
	MaxHp = temp_data["hp"]
	Skills = temp_data["skills"]
	
func get_entity_name():
	return Name

func get_skills():
	return Skills
	
func get_hp():
	return Hp

func get_max_hp():
	return MaxHp
	
func deal_dmg():
	pass
	
func get_dmg(attack_item):
	pass

