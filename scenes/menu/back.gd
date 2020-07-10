extends "res://scripts/label_hover.gd"

func _on_gui_input(event : InputEvent):
	if (event.is_pressed()):
		get_parent().hide()
		get_parent().get_parent().get_node("main").show()
		reset_hover()


func _on_popup_back_pressed():
	get_node("/root/menu/popup").hide()
