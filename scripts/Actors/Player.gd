class_name Player extends Lucjan


func _init():
	character_file_path = "res://Data/mikut_data.json"


func _ready():
	load_data()

func use_item(item):
	if item[1] != 0:
		Hp -= int(item[1])
	elif item[2] != 0:
		Hp += int(item[2])
	saveData()

func set_eq(eq):
	Equipment = eq
	saveData()

func unlock():
	$PlayerBody.unlock_movement()
func lock():
	$PlayerBody.lock_movement()

func _process(delta):
	pass
