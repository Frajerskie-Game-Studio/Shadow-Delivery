extends Node

signal start_dialog(path)

func _ready():
	#var d = DialogLoader.new()
	#d.load_data("res://Data/npc_test.json")
	#d.showDialog.connect(_on_npc_show_dialog)
	#d.start_dialog()
	
	$DeskDialog.load_data("res://Data/desk.json", true, false)
	$BedDialog.load_data("res://Data/desk.json", true, false)


func _process(delta):
	pass


func _on_desk_dialog_start_dialog(path, d):
	start_dialog.emit(path, d)
