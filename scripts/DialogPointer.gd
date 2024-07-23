extends Area2D

var CurrentDialogState
var dialogStates

signal start_dialog

func load_data(path):
	var text = FileAccess.get_file_as_string(path)
	var temp_data = JSON.parse_string(text)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func end_dialog():
	pass
