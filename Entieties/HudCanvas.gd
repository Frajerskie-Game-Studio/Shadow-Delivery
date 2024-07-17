extends CanvasLayer


var dialog_name
var text
var dialog_index = 0
signal end_dialog
func _ready():
	pass
	
func load_data(npc_name, npc_text):
	dialog_name = npc_name
	text = npc_text
	$Control.load_data(text[dialog_index][0], text[dialog_index][1])
	
func _process(delta):
	pass

func _on_control_next_line():
	dialog_index+=1
	if dialog_index < len(text):
		$Control.load_data(text[dialog_index][0], text[dialog_index][1])
	else:
		dialog_index = 0
		get_parent().end_dialog()
		self.queue_free()
