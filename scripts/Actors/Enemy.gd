extends Node2D

@onready var HealthBar = $HealthBar

var Name
var Hp
var MaxHp
var Attack
var Skills

var attack_danger = false
var on_cursor = false

signal being_attacked(entity)

func _ready():
	HealthBar.max_value = MaxHp
	HealthBar.value = MaxHp

func _process(delta):
	if attack_danger and on_cursor:
		if Input.is_action_just_pressed("mouse_click"):
			being_attacked.emit(self)
			attack_danger = false
			on_cursor = false
			$CheckSprite.visible = false

func load_data(json_path):
	var text = FileAccess.get_file_as_string(json_path)
	var temp_data = JSON.parse_string(text)
	Name = temp_data["name"]
	Hp = temp_data["hp"]
	MaxHp = temp_data["hp"]
	Skills = temp_data["skills"]
	
func get_entity_name():
	return Name

func get_skills():
	return Skills
	
func get_hp():
	return Hp

func get_max_hp():
	return MaxHp
	
func deal_dmg():
	pass
	
func get_dmg(attack):
	Hp -= attack.dmg
	HealthBar.value = Hp
	if Hp <= 0:
		queue_free()



func _on_area_2d_mouse_entered():
	if attack_danger:
		on_cursor = true
		$CheckSprite.visible = true


func _on_area_2d_mouse_exited():
	if attack_danger:
		on_cursor = false
		$CheckSprite.visible = false
