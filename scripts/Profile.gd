extends  MarginContainer

@onready var Name
@onready var Hp
@onready var MaxHp
var choosingUnlocked = false
var ableToChoose = false
signal selectTeammate(e_name)

func set_values():
	$MarginContainer/HBoxContainer/VBoxContainer/Name.text = Name
	$MarginContainer/HBoxContainer/VBoxContainer/Healthbar.max_value = MaxHp
	$MarginContainer/HBoxContainer/VBoxContainer/Healthbar.value = Hp

func _ready():
	print("Name")
	set_values()


func _process(delta):
	if ableToChoose:
		if Input.is_action_just_pressed("mouse_click"):
			print(Name)
			selectTeammate.emit(Name)
	
func load_data(e_name, e_hp, e_maxHp):
	Name = e_name
	Hp = e_hp
	MaxHp = e_maxHp
	
func unlock_choosing():
	choosingUnlocked = true

func lock_choosing():
	choosingUnlocked = false
	ableToChoose = false

func _on_mouse_entered():
	if choosingUnlocked:
		ableToChoose = true


func _on_mouse_exited():
	if choosingUnlocked:
		ableToChoose = false
