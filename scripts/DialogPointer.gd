extends Area2D

var Path
var Clickable = false
var Ready = false
var Deletable
var DuringDialog = false
var Action

signal start_dialog(path, dialog_pointer, action)

func load_data(path, clickable, deletable, action):
	Path = path
	Clickable = clickable
	Deletable = deletable
	Action = action

func _ready():
	pass


func _process(delta):
	if Clickable:
		if Ready:
			if Input.is_action_just_pressed("mouse_click"):
				print("IM EMMITING")
				$Indicator.visible = false
				Ready = false
				DuringDialog = true
				start_dialog.emit(Path, self, Action)



func _on_body_entered(body):
	if body.get_class() == "Node2D":
		if !Clickable:
			start_dialog.emit(Path, self, Action)
	


func _on_mouse_entered():
	if Clickable and !DuringDialog:
		print("ENTERED")
		Ready = true
		$Indicator.visible = true


func _on_body_exited(body):
	if Clickable and !DuringDialog:
		Ready = false
		$Indicator.visible = false
