extends Node2D

var Name
var Hp
var Skills
var MaxHp

func saveData():
	var file = FileAccess.open("res://Data/lucjan_data.json", FileAccess.WRITE)
	var temp_data = {
		"name": name,
		"texture": "",
		"hp": Hp,
		"max_hp": MaxHp,
		"skills": Skills,
	}
	file.store_string(JSON.stringify(temp_data, "\t"))
	file.close()

func load_data():
	var text = FileAccess.get_file_as_string("res://Data/lucjan_data.json")
	var temp_data = JSON.parse_string(text)
	Name = temp_data["name"]
	Hp = temp_data["hp"]
	MaxHp = temp_data["hp"]
	Skills = temp_data["skills"]	

func _ready():
	load_data()

func use_item(item):
	if item[1] != 0:
		Hp -= item[1]
	elif item[2] != 0:
		Hp += item[2]
	saveData()

func get_entity_name():
	return Name

func get_skills():
	return Skills
	
func get_hp():
	return Hp

func _process(delta):
	pass
