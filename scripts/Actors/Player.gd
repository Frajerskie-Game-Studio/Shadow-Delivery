extends "Lucjan.gd"

func _init():
	character_file_path = "res://Data/mikut_data.json"

func _ready():
	#hp, max_hp, mele_skills, range_skills, ammo, ammo_texture_path
	print($AttackMenu.visible)
	load_data()
	load_items()
	load_res()
	reload_menu()
	if in_battle:
		$AttackMenu.load_data(Hp, MaxHp, Skills, get_ammo(), "", Items)
		$AttackMenu.visible =true
		if KnockedUp:
			can_be_attacked = false
			animationState.travel("knocked_down")

		elif current_style == "melee":
			animationState.travel("mele_idle")
		elif current_style == "range":
			animationState.travel("range_idle")
	else:
		$AttackMenu.visible = false




func unlock():
	$PlayerBody.unlock_movement()


func lock():
	$PlayerBody.lock_movement()


func reload_menu():
	$AttackMenu.load_data(Hp, MaxHp, Skills, get_ammo(), "", Items)

		
func get_animation_tree():
	return $AnimationTree
