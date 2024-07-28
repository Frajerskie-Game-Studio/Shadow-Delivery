extends  MarginContainer

@onready var Name 
@onready var Hp 
@onready var MaxHp 
@onready var KnockedUp
var choosingUnlocked = false
var ableToChoose = false
var choosingAction = ""
signal selectTeammate(e_name)

func set_values():
	if Name != null:
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
			selectTeammate.emit(Name, choosingAction)
	else:
		if $Panel.has_theme_stylebox_override("panel"):
			$Panel.remove_theme_stylebox_override("panel")


func load_data(e_name, e_hp, e_maxHp, texture, e_knockedUp):
	Name = e_name
	Hp = e_hp
	MaxHp = e_maxHp
	KnockedUp = e_knockedUp
	$MarginContainer/HBoxContainer/TextureRect.texture = load(texture)


func unlock_choosing(cAction):
	choosingUnlocked = true
	choosingAction = cAction


func lock_choosing():
	choosingUnlocked = false
	ableToChoose = false
	choosingAction = ""


func _on_mouse_entered():
	if choosingUnlocked:
		ableToChoose = true
		var stylebox:StyleBoxFlat = $Panel.get_theme_stylebox("panel").duplicate() 
		stylebox.border_color = Color.WHITE
		stylebox.border_width_bottom = 5
		stylebox.border_width_right = 5
		stylebox.border_width_left = 5
		stylebox.border_width_top = 5
		$Panel.add_theme_stylebox_override("panel", stylebox)

func _on_mouse_exited():
	if choosingUnlocked:
		ableToChoose = false
		$Panel.remove_theme_stylebox_override("panel")
