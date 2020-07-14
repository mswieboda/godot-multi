extends VBoxContainer

onready var main = get_parent().get_node("main")
onready var lobbies = get_parent().get_node("lobbies")
onready var lobby = get_parent().get_node("lobby")
onready var popup = get_node("/root/menu/popup")

func _ready():
	Network.connect("server_created", self, "_on_server_created")
	Network.connect("server_joined", self, "_on_server_joined")


func _on_server_created():
	showLobby()


func _on_server_joined():
	showLobby()


func showLobby():
	hide()
	lobby.show()


func _on_create_gui_input(event : InputEvent):
	if (event.is_pressed()):
		popup.show_create()


func _on_join_gui_input(event : InputEvent):
	if (event.is_pressed()):
		hide()
		lobbies.show()
		lobbies.load_lobbies()


func _on_back_gui_input(event : InputEvent):
	if (event.is_pressed()):
		hide()
		main.show()