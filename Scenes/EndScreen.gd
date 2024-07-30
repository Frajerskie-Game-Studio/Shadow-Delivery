extends Node



func _ready():
	$CanvasLayer/AnimationPlayer.play("ShowAnimation")


func _process(delta):
	pass


func _on_back_to_menu_pressed():
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")


func _on_leave_pressed():
	JavaScriptBridge.eval("window.close()")
	get_tree().quit()
