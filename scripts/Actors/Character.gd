extends Node2D


var Name
var Hp
var MaxHp
var Skills
var Equipment

var character_file_path

func saveData():
	var file = FileAccess.open(character_file_path, FileAccess.WRITE)
	var temp_data = {
		"name": Name,
		"texture": "",
		"hp": Hp,
		"max_hp": MaxHp,
		"skills": Skills,
		"equipment": Equipment
	}
	file.store_string(JSON.stringify(temp_data, "\t", false))
	file.close()


func load_data():
	var text = FileAccess.get_file_as_string(character_file_path)
	var temp_data = JSON.parse_string(text)
	Name = temp_data["name"]
	Hp = temp_data["hp"]
	MaxHp = temp_data["hp"]
	Skills = temp_data["skills"]
	Equipment = temp_data["equipment"]


func _ready():
	load_data()


func use_item(item):
	if item[1] != 0:
		Hp -= int(item[1])
	elif item[2] != 0:
		Hp += int(item[2])
	saveData()


func get_entity_name():
	return Name


func get_skills():
	return Skills


func get_hp():
	return Hp


func get_max_hp():
	return MaxHp


func get_eq():
	return Equipment


func set_eq(eq):
	Equipment = eq
	saveData()


func _process(delta):
	pass
