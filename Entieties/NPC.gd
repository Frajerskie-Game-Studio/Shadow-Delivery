extends StaticBody2D

@onready var npc_name
@onready var current_dialog_position
@onready var npc_data

signal showDialog(npc_name, dialog_dict, dialog_npc)

var ableToTalk = false
var block = false
var dialogStates


func writeToJson():
	var file = FileAccess.open("./Data/npc_test.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(npc_data))
	file.close()
	

func _ready():
	var text = FileAccess.get_file_as_string("./Data/npc_test.json")
	npc_data = JSON.parse_string(text)
	
	npc_name = npc_data["name"]
	dialogStates = npc_data["dialogStates"]
	current_dialog_position = npc_data["currentDialogState"] 
	
func _process(delta):
	if ableToTalk and !block:
		if Input.is_action_just_pressed("mouse_click"):
			print("showDialog")
			block = true
			showDialog.emit(npc_name, npc_data[dialogStates[current_dialog_position]], self)
			if current_dialog_position < len(dialogStates) - 1:
				current_dialog_position+=1
				npc_data["currentDialogState"] = current_dialog_position
			writeToJson()
			
func end_dialog():
	block = false

func _on_mouse_entered():
	if !block:
		ableToTalk = true
		$AnimatedSprite2D.visible = true
		$AnimatedSprite2D.play()


func _on_mouse_exited():
	if !block:
		ableToTalk = false
		$AnimatedSprite2D.visible = false
		$AnimatedSprite2D.stop()
