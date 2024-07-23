extends MarginContainer

@onready var AttackButton = $HBoxContainer/LeftMenu/AttackButton
@onready var SkillsButton = $HBoxContainer/LeftMenu/SkillsButton
@onready var ItemsButton = $HBoxContainer/LeftMenu/ItemsButton
@onready var ChangeStyleButton = $HBoxContainer/RightMenu/ChangeAndTime/ChangeStyle
@onready var WaitTimeBar = $HBoxContainer/RightMenu/ChangeAndTime/WaitTimeBar
@onready var HealthBar = $HBoxContainer/RightMenu/HealthBar
@onready var AmmoLabel = $HBoxContainer/RightMenu/RangeWeaponStats/Ammo
@onready var AmmoTexture = $HBoxContainer/RightMenu/RangeWeaponStats/TextureRect


var Skills
var CurrentStyle = "mele"
var WaitTime
var Ammo
var Items

signal i_will_attack(args)
signal change_style

func load_data(hp, max_hp, skills, ammo, ammo_texture_path, items):
	print(hp)
	print(max_hp)
	HealthBar.max_value = max_hp
	HealthBar.value = hp
	Skills = skills
	Ammo = ammo
	AmmoLabel.text = str(ammo)
	Items = items
	print(Skills)
	#AmmoTexture.texture = ammo_texture_path

func _ready():
	pass

func _process(delta):
	if CurrentStyle == "range":
		if Ammo <= 0:
			AttackButton.disabled = true
		else:
			AttackButton.disabled = false
	else:
		AttackButton.disabled = false


func _on_attack_button_pressed():
	i_will_attack.emit(null)
	$HBoxContainer/RightMenu/SkillsMenu.visible = false


func _on_change_style_pressed():
	change_style.emit()
	if CurrentStyle == "mele":
		CurrentStyle = "range"
	else:
		CurrentStyle = "mele"
	


func _on_skills_button_pressed():
	$HBoxContainer/RightMenu/SkillsMenu/SkillsList.clear()
	$HBoxContainer/RightMenu/SkillsMenu/Panel/SkillDesc.text = ""
	if !$HBoxContainer/RightMenu/SkillsMenu.visible:
		for key in Skills:
			if Skills[key][4] == CurrentStyle or Skills[key][4] == "other":
				$HBoxContainer/RightMenu/SkillsMenu/SkillsList.add_item(str(key).replace("_", " "))
		$HBoxContainer/RightMenu/ItemsMenu.visible = false
		$HBoxContainer/RightMenu/SkillsMenu.visible = true
		$HBoxContainer/RightMenu/ChangeAndTime.visible = false
	else:
		$HBoxContainer/RightMenu/SkillsMenu/SkillsList.clear()
		$HBoxContainer/RightMenu/SkillsMenu.visible = false
		$HBoxContainer/RightMenu/ChangeAndTime.visible = true

func _on_skills_list_item_clicked(index, at_position, mouse_button_index):
	var item = $HBoxContainer/RightMenu/SkillsMenu/SkillsList.get_item_text(index)
	$HBoxContainer/RightMenu/SkillsMenu/Panel/SkillDesc.text = Skills[str(item).replace(" ", "_")][0]


func _on_skills_list_item_activated(index):
	var item = $HBoxContainer/RightMenu/SkillsMenu/SkillsList.get_item_text(index)
	if Skills[str(item).replace(" ", "_")][4] == "range" and Ammo <=0:
		pass
	else:
		i_will_attack.emit(Skills[str(item).replace(" ", "_")])
		$HBoxContainer/RightMenu/SkillsMenu.visible = false
		$HBoxContainer/RightMenu/ChangeAndTime.visible = true
		$HBoxContainer/RightMenu/SkillsMenu/SkillsList.clear()
		$HBoxContainer/RightMenu/SkillsMenu/Panel/SkillDesc.text = ""


func _on_items_button_pressed():
	$HBoxContainer/RightMenu/ItemsMenu/ItemsList.clear()
	$HBoxContainer/RightMenu/ItemsMenu/Panel/HBoxContainer/ItemDesc.text = ""
	$HBoxContainer/RightMenu/ItemsMenu/Panel/HBoxContainer/ItemAmmount.text = ""
	if !$HBoxContainer/RightMenu/ItemsMenu.visible:
		for key in Items:
			$HBoxContainer/RightMenu/ItemsMenu/ItemsList.add_item(str(key).replace("_", " "))
		$HBoxContainer/RightMenu/SkillsMenu.visible = false
		$HBoxContainer/RightMenu/ItemsMenu.visible = true
		$HBoxContainer/RightMenu/ChangeAndTime.visible = false
	else:
		$HBoxContainer/RightMenu/ItemsMenu/ItemsList.clear()
		$HBoxContainer/RightMenu/ItemsMenu.visible = false
		$HBoxContainer/RightMenu/ChangeAndTime.visible = true


func _on_items_list_item_clicked(index, at_position, mouse_button_index):
	var item = $HBoxContainer/RightMenu/ItemsMenu/ItemsList.get_item_text(index)
	$HBoxContainer/RightMenu/ItemsMenu/Panel/HBoxContainer/ItemDesc.text = str(Items[item][0])
	$HBoxContainer/RightMenu/ItemsMenu/Panel/HBoxContainer/ItemAmmount.text = "Ammount: " + str(Items[item][3])


func _on_items_list_item_activated(index):
	var item = $HBoxContainer/RightMenu/ItemsMenu/ItemsList.get_item_text(index)
	print(item)
	if Items[item][3] <= 0:
		pass
	else:
		i_will_attack.emit([Items[item], item])
		$HBoxContainer/RightMenu/ItemsMenu.visible = false
		$HBoxContainer/RightMenu/ChangeAndTime.visible = true
		$HBoxContainer/RightMenu/ItemsMenu/ItemsList.clear()
		$HBoxContainer/RightMenu/ItemsMenu/Panel/HBoxContainer/ItemDesc.text = ""
		$HBoxContainer/RightMenu/ItemsMenu/Panel/HBoxContainer/ItemAmmount.text = ""

