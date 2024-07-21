extends MarginContainer

@onready var AttackButton = $HBoxContainer/LeftMenu/AttackButton
@onready var SkillsButton = $HBoxContainer/LeftMenu/SkillsButton
@onready var ItemsButton = $HBoxContainer/LeftMenu/ItemsButton
@onready var ChangeStyleButton = $HBoxContainer/RightMenu/ChangeAndTime/ChangeStyle
@onready var WaitTimeBar = $HBoxContainer/RightMenu/ChangeAndTime/WaitTimeBar
@onready var HealthBar = $HBoxContainer/RightMenu/HealthBar
@onready var AmmoLabel = $HBoxContainer/RightMenu/RangeWeaponStats/Ammo
@onready var AmmoTexture = $HBoxContainer/RightMenu/RangeWeaponStats/TextureRect


var MeleSkills
var RangeSkills
var CurrentStyle = "mele"
var WaitTime
var Ammo

signal i_will_attack()
signal change_style

func load_data(hp, max_hp, mele_skills, range_skills, ammo, ammo_texture_path):
	HealthBar.max_value = max_hp
	HealthBar.value = hp
	MeleSkills = mele_skills
	RangeSkills = range_skills
	Ammo = ammo
	AmmoLabel.text = str(ammo)
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
	i_will_attack.emit()


func _on_change_style_pressed():
	change_style.emit()
	if CurrentStyle == "mele":
		CurrentStyle = "range"
	else:
		CurrentStyle = "mele"
	
