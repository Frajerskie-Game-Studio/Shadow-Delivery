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
var CurrentStyle = "melee"
var WaitTime
var Ammo
var Items
var in_tutorial = false

signal i_will_attack(args)
signal change_style

func load_data(hp, max_hp, skills, ammo, ammo_texture_path, items):
	HealthBar.max_value = max_hp
	HealthBar.value = hp
	Skills = skills
	Ammo = ammo
	AmmoLabel.text = str(ammo)
	Items = items
	#AmmoTexture.texture = ammo_texture_path

func _ready():
	pass

func _process(delta):
	if get_parent().in_battle and !get_parent().KnockedUp:
		visible = true
	else:
		visible = false
	
	if !in_tutorial:
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
	$HBoxContainer/RightMenu/ItemsMenu.visible = false


func _on_change_style_pressed():
	change_style.emit()
	if CurrentStyle == "melee":
		CurrentStyle = "range"
	else:
		CurrentStyle = "melee"

func _on_skills_button_pressed():
	print("SKILLL BUTTON PRESSED")
	print(CurrentStyle)
	$HBoxContainer/RightMenu/SkillsMenu/SkillsList.clear()
	$HBoxContainer/RightMenu/SkillsMenu/Panel/SkillDesc.text = ""
	print($HBoxContainer/RightMenu/SkillsMenu.visible)
	print(Skills)
	if !$HBoxContainer/RightMenu/SkillsMenu.visible:
		for skill in Skills:
			print(skill)
			if skill.type == CurrentStyle or skill.type == "other":
				$HBoxContainer/RightMenu/SkillsMenu/SkillsList.add_item(skill.name)
		$HBoxContainer/RightMenu/ItemsMenu.visible = false
		$HBoxContainer/RightMenu/SkillsMenu.visible = true
		$HBoxContainer/RightMenu/ChangeAndTime.visible = false
	else:
		$HBoxContainer/RightMenu/SkillsMenu/SkillsList.clear()
		$HBoxContainer/RightMenu/SkillsMenu.visible = false
		$HBoxContainer/RightMenu/ChangeAndTime.visible = true

func _on_skills_list_item_clicked(index, at_position, mouse_button_index):
	var item = $HBoxContainer/RightMenu/SkillsMenu/SkillsList.get_item_text(index)
	$HBoxContainer/RightMenu/SkillsMenu/Panel/SkillDesc.text = Skills[index].description


func _on_skills_list_item_activated(index):
	var item = $HBoxContainer/RightMenu/SkillsMenu/SkillsList.get_item_text(index)
	if Skills[index].type == "range" and Ammo <= 0:
		pass
	else:
		i_will_attack.emit(Skills[index])
		$HBoxContainer/RightMenu/SkillsMenu.visible = false
		$HBoxContainer/RightMenu/ChangeAndTime.visible = true
		$HBoxContainer/RightMenu/SkillsMenu/SkillsList.clear()
		$HBoxContainer/RightMenu/SkillsMenu/Panel/SkillDesc.text = ""


func _on_items_button_pressed():
	$HBoxContainer/RightMenu/ItemsMenu/ItemsList.clear()
	$HBoxContainer/RightMenu/ItemsMenu/Panel/HBoxContainer/ItemDesc.text = ""
	$HBoxContainer/RightMenu/ItemsMenu/Panel/HBoxContainer/ItemAmmount.text = ""
	if !$HBoxContainer/RightMenu/ItemsMenu.visible:
		for item in Items:
			$HBoxContainer/RightMenu/ItemsMenu/ItemsList.add_item(item.name, load(item.icon_path))
		$HBoxContainer/RightMenu/SkillsMenu.visible = false
		$HBoxContainer/RightMenu/ItemsMenu.visible = true
		$HBoxContainer/RightMenu/ChangeAndTime.visible = false
	else:
		$HBoxContainer/RightMenu/ItemsMenu/ItemsList.clear()
		$HBoxContainer/RightMenu/ItemsMenu.visible = false
		$HBoxContainer/RightMenu/ChangeAndTime.visible = true


func _on_items_list_item_clicked(index, at_position, mouse_button_index):
	#var item = $HBoxContainer/RightMenu/ItemsMenu/ItemsList.get_item_text(index)
	$HBoxContainer/RightMenu/ItemsMenu/Panel/HBoxContainer/ItemDesc.text = Items[index].description
	$HBoxContainer/RightMenu/ItemsMenu/Panel/HBoxContainer/ItemAmmount.text = "Ammount: " + str(Items[index].amount)


func _on_items_list_item_activated(index):
	var item = $HBoxContainer/RightMenu/ItemsMenu/ItemsList.get_item_text(index)
	if Items[index].amount <= 0:
		pass
	else:
		i_will_attack.emit(Items[index])
		$HBoxContainer/RightMenu/ItemsMenu.visible = false
		$HBoxContainer/RightMenu/ChangeAndTime.visible = true
		$HBoxContainer/RightMenu/ItemsMenu/ItemsList.clear()
		$HBoxContainer/RightMenu/ItemsMenu/Panel/HBoxContainer/ItemDesc.text = ""
		$HBoxContainer/RightMenu/ItemsMenu/Panel/HBoxContainer/ItemAmmount.text = ""
		
func lock_buttons():
	$HBoxContainer/LeftMenu/AttackButton.disabled = true
	$HBoxContainer/LeftMenu/AttackButton.release_focus()
	$HBoxContainer/LeftMenu/SkillsButton.disabled = true
	$HBoxContainer/RightMenu/SkillsMenu.release_focus()
	$HBoxContainer/LeftMenu/ItemsButton.disabled = true
	$HBoxContainer/LeftMenu/ItemsButton.release_focus()
	
func unlock_buttons():
	$HBoxContainer/LeftMenu/AttackButton.disabled = false
	$HBoxContainer/LeftMenu/SkillsButton.disabled = false
	$HBoxContainer/LeftMenu/ItemsButton.disabled = false
	
func lock_change_style():
	$HBoxContainer/RightMenu/ChangeAndTime/ChangeStyle.disabled = true

func unlock_specific_button(button_name):
	if button_name == "attack":
		$HBoxContainer/LeftMenu/AttackButton.disabled = false
	elif button_name == "skills":
		$HBoxContainer/LeftMenu/SkillsButton.disabled = false
	elif button_name == "items":
		$HBoxContainer/LeftMenu/ItemsButton.disabled = false
	elif button_name == "change":
		$HBoxContainer/RightMenu/ChangeAndTime/ChangeStyle.disabled = false
