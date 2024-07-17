extends Panel

@onready var writetext = false
var dialog_text

signal next_line

func _ready():
	pass
	
func load_data(npc_name, npc_text):
	dialog_text = npc_text
	$VBoxContainer/MarginContainer/Name.text = npc_name
	$VBoxContainer/MarginContainer2/RichTextLabel.text = dialog_text
	writetext = true

func _process(delta):
	if writetext:
		if $VBoxContainer/MarginContainer2/RichTextLabel.visible_characters < dialog_text.length():
			$VBoxContainer/MarginContainer2/RichTextLabel.visible_characters += 1
		else:
			$VBoxContainer/MarginContainer2/RichTextLabel.visible_characters = -1
			writetext = false
	elif Input.is_action_just_pressed("mouse_click"):
		next_line.emit()
			
			
