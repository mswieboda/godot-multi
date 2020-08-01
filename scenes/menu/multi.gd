extends "res://scenes/menu/menu.gd"

onready var play = get_parent().get_node("play")
onready var lobbies = get_parent().get_node("lobbies")
onready var lobby = get_parent().get_node("lobby")
onready var popup = get_node("/root/menu/popup")


func _ready():
# warning-ignore:return_value_discarded
	Network.connect("server_created", self, "_on_server_created")


func _on_server_created():
	go_to(lobby)


func _on_create_gui_input(event : InputEvent):
	if (event.is_pressed()):
		popup.show_create()


func _on_join_gui_input(event : InputEvent):
	if (is_pressed_go_to(event, lobbies)):
		lobbies.load_lobbies()


func _on_back_gui_input(event : InputEvent):
	is_pressed_go_to(event, play)
