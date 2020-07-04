extends "res://scripts/label_hover.gd"

func _on_join_gui_input(event : InputEvent):
	if (event.is_pressed()):
		Global.is_server = true
		get_tree().change_scene("res://scenes/lobby/lobby.tscn")
