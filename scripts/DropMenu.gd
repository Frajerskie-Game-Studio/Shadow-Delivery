extends MarginContainer

signal endFight

func _ready():
	pass

func _process(delta):
	pass


func _on_button_pressed():
	endFight.emit()
