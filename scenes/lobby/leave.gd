extends "res://scripts/label_hover.gd"

func _on_leave_gui_input(event):
	if (event.is_pressed()):
		print("leave, disconnecting (NYI)")
		get_tree().change_scene("res://scenes/lobbies/lobbies.tscn")
