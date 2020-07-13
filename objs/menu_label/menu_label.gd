extends "res://scripts/label_hover.gd"


func _on_gui_input(event):
	if event.is_pressed():
		reset_hover()
