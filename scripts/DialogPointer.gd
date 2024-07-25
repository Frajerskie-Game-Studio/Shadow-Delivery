extends Area2D

var Path
var Clickable = false
var Ready = false
var Deletable
var DuringDialog = false
var Action
var MultiState = false

signal start_dialog(path, dialog_pointer, action)

func move_dialog_index():
	var text = FileAccess.get_file_as_string(Path)
	var dialog_data = JSON.parse_string(text)
	if len(dialog_data.dialogStates) - 1 > dialog_data.currentDialogState:
		dialog_data.currentDialogState+=1 
		var file = FileAccess.open(Path, FileAccess.WRITE)
		file.store_string(JSON.stringify(dialog_data, "\t"))
		file.close()

func load_data(path, clickable, deletable, action, multi_state):
	Path = path
	Clickable = clickable
	Deletable = deletable
	Action = action
	MultiState = multi_state

func _ready():
	pass


func _process(delta):
	if Clickable:
		if Ready:
			if Input.is_action_just_pressed("mouse_click"):
				$Indicator.visible = false
				Ready = false
				DuringDialog = true
				start_dialog.emit(Path, self, Action)

func _on_body_entered(body):
	if body.get_class() == "CharacterBody2D":
		if !Clickable:
			start_dialog.emit(Path, self, Action)
	


func _on_mouse_entered():
	if Clickable and !DuringDialog:
		Ready = true
		$Indicator.visible = true

func _on_mouse_exited():
	if Clickable and !DuringDialog:
		Ready = false
		$Indicator.visible = false

func end_dialog():
	DuringDialog = false
	if MultiState:
		move_dialog_index()
