extends Control

@onready var NameLabel = $MarginContainer/Panel/MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/Name
@onready var HpBar = $MarginContainer/Panel/MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/ProgressBar
var Name
var Hp

func _ready():
	NameLabel.text = Name
	HpBar.max_value = Hp
	HpBar.value = Hp

func load_data(Namme, Hpp):
	print(Namme)
	print(Hp)
	Name = Namme
	Hp = Hpp
	#HpBar.max_value = Hp
	#HpBar.value = Hp
	
func _process(delta):
	pass
