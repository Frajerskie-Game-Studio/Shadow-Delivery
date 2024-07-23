extends Node

var currentDialogState
var dialogStates
var dialog_data

signal showDialog(npc_name, dialog_dict, dialog_npc)

func load_data(path):
	var text = FileAccess.get_file_as_string(path)
	dialog_data = JSON.parse_string(text)
	currentDialogState = dialog_data.currentDialogState
	dialogStates = dialog_data.dialogStates
	
func start_dialog():
	showDialog.emit(dialog_data.name, dialog_data[dialogStates[currentDialogState]], null)
	

func _ready():
	pass

func _process(delta):
	pass
