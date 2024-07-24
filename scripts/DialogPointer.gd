extends Area2D

var Path
var Clickable = false
var Ready = false
var Deletable

signal start_dialog(path)

func load_data(path, clickable, deletable):
	Path = path
	Clickable = clickable
	Deletable = deletable
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Clickable:
		if Ready:
			if Input.is_action_just_pressed("mouse_click"):
				start_dialog.emit(Path, self)


func _on_body_entered(body):
	if body.get_class() == "Node2D":
		if !Clickable:
			start_dialog.emit(Path, self)
	


func _on_mouse_entered():
	if Clickable:
		Ready = true
		$Indicator.visible = true


func _on_body_exited(body):
	if Clickable:
		Ready = false
		$Indicator.visible = false
