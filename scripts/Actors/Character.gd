extends Node2D


var Name
var Hp
var MaxHp
var Skills
var Equipment
var Attack
var Items
var Party_Data

var character_file_path
var duringSkillCheck = false
var skillCheckFailed = true
var waiting = false
var can_be_attacked = true
var ready_to_attack_bool = false
var changing_style = false
var can_be_checked = false
var on_mouse_cursor = false
var selected_attack
var current_style = "mele"


signal ready_to_attack()
signal attacking
signal reset_attack

func saveItems():
	var file = FileAccess.open("res://Data/party_data.json", FileAccess.WRITE)
	var temp_data = {
		"teammates": Party_Data.teammates,
		"items": Items,
		"equipment": Party_Data.equipment
	}
	file.store_string(JSON.stringify(temp_data, "\t", false))
	file.close()

func saveData():
	var file = FileAccess.open(character_file_path, FileAccess.WRITE)
	var temp_data = {
		"name": Name,
		"texture": "",
		"hp": Hp,
		"max_hp": MaxHp,
		"attack": Attack,
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
	MaxHp = temp_data["max_hp"]
	Skills = temp_data["skills"]
	Equipment = temp_data["equipment"]
	Attack = temp_data["attack"]

func load_items():
	var text = FileAccess.get_file_as_string("res://Data/party_data.json")
	var temp_data = JSON.parse_string(text)
	Items = temp_data.items
	Party_Data = temp_data

func _ready():
	load_data()
	load_items()

func get_ammo():
	return Equipment.Range_weapon[3]

func decrement_ammo():
	Equipment.Range_weapon[3] -= 1

func get_style():
	return current_style

func set_style():
	if current_style == "mele":
		current_style = "range"
	else:
		current_style = "mele"

func use_item(item):
	if item[1] != 0:
		Hp -= int(item[1])
	elif item[2] != 0:
		Hp += int(item[2])
	Items[item[0]][3] -= 1
	if Items[item[0]][3] <= 0:
		Items.erase(item[0])
	saveData()
	saveItems()

func get_attack():
	return Attack

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
	#if duringSkillCheck:
		#print("wot")
		#if Input.is_action_pressed("move_left"):
			#print("pressed")
			#duringSkillCheck = false
