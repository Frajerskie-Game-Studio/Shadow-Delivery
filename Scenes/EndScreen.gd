extends Node



func _ready():
	$CanvasLayer/AnimationPlayer.play("ShowAnimation")


func _process(delta):
	pass


func _on_back_to_menu_pressed():
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")


func _on_leave_pressed():
	get_tree().quit()


func _on_animation_player_animation_finished(anim_name):
	$Panel.visible = false
