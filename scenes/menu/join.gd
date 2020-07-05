extends "res://scripts/label_hover.gd"

func _on_gui_input(event : InputEvent):
	if (event.is_pressed()):
		Global.is_server = false
		Global.server_ip = Global.SERVER_IP
		get_tree().change_scene("res://scenes/lobby/lobby.tscn")
