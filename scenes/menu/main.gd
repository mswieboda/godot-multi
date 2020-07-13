extends VBoxContainer


onready var play_menu = get_parent().get_node("play menu")


func _on_play_gui_input(event):
	if event.is_pressed():
		hide()
		play_menu.show()


func _on_quit_gui_input(event):
	if event.is_pressed():
		get_tree().quit()
