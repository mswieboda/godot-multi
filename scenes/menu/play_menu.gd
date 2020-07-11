extends VBoxContainer

onready var lobby = get_parent().get_node("lobby")

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
