extends Control


func start():
	get_tree().change_scene("res://main.tscn")


func leave():
	$err.popup_centered(Vector2(611, 220))


func suffering(button_pressed):
	GameST.one_hp = button_pressed
