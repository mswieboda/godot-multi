extends "res://scripts/label_hover.gd"

func _on_gui_input(event : InputEvent):
	if event.is_pressed():
		get_parent().hide()
		get_parent().get_parent().get_node("play").show()
		reset_hover()
		#get_tree().change_scene("res://scenes/lobby menu/lobby menu.tscn")
