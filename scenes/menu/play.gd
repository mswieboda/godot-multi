extends "res://objs/menu_label/menu_label.gd"


func _on_gui_input(event : InputEvent):
	if event.is_pressed():
		get_parent().hide()
		get_parent().get_parent().get_node("play menu").show()
		reset_hover()
