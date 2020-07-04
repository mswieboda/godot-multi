extends "res://scripts/label_hover.gd"


func _on_back_gui_input(event : InputEvent):
	if (event.is_pressed()):
		print_debug("back!")
		get_tree().change_scene("res://scenes/menu/menu.tscn")

