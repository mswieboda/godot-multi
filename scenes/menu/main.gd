extends "res://scenes/menu/menu.gd"

onready var play = get_parent().get_node("play")
onready var settings = get_parent().get_node("settings")


func _on_play_gui_input(event):
	is_pressed_go_to(event, play)


func _on_settings_gui_input(event):
	is_pressed_go_to(event, settings)


func _on_quit_gui_input(event):
	if event.is_pressed():
		get_tree().quit()
