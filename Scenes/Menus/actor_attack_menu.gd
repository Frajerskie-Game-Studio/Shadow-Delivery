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

signal i_will_attack(args)
signal change_style

func load_data(hp, max_hp, skills, ammo, ammo_texture_path):
	HealthBar.max_value = max_hp
	HealthBar.value = hp
	Skills = skills
	Ammo = ammo
	AmmoLabel.text = str(ammo)
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
	if !$HBoxContainer/RightMenu/SkillsMenu.visible:
		for key in Skills:
			if Skills[key][4] == CurrentStyle or Skills[key][4] == "other":
				$HBoxContainer/RightMenu/SkillsMenu/SkillsList.add_item(str(key).replace("_", " "))
		$HBoxContainer/RightMenu/SkillsMenu.visible = true
		$HBoxContainer/RightMenu/ChangeAndTime.visible = false
	else:
		$HBoxContainer/RightMenu/SkillsMenu/SkillsList.clear()
		$HBoxContainer/RightMenu/SkillsMenu.visible = false
		$HBoxContainer/RightMenu/ChangeAndTime.visible = true
		$HBoxContainer/RightMenu/SkillsMenu/Panel/SkillDesc.text = ""

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
