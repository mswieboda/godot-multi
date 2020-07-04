extends Node

var players = {}
onready var playerList = get_node("HBoxContainer/VBoxContainer/menu items/players")

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().connect("network_peer_connected", self, "_network_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_network_peer_disconnected")
	get_tree().connect("connection_failed", self, "_connection_failed")
	
	var peer
	var status
	
	if (Global.is_server):
		print_debug("creating lobby as server")
		peer = NetworkedMultiplayerENet.new()
		status = peer.create_server(Global.SERVER_PORT, Global.MAX_PLAYERS)
	else:
		print_debug("joining lobby as client")
		peer = NetworkedMultiplayerENet.new()
		status = peer.create_client(Global.server_ip, Global.SERVER_PORT)
	
	if (status != OK):
			print_debug("server error")
			return
	
	get_tree().network_peer = peer


func _network_peer_connected(id):
	print_debug("peer connected: " + id)
	rpc_id(id, "player_joined", id)
	rpc("player_joined", id)
	player_joined(id)


func _network_peer_disconnected(id):
	print_debug("peer disconnected: " + id)
	rpc_id(id, "player_left", id)


func _connection_failed():
	print_debug("connection failed")


remote func player_joined(id):
	print_debug("player " + id + " joined")
	
	players[id] = id
	
	var label = Label.new()
	
	label.text = "client " + id
	
	if (id == 1):
		label.text += " (server)"
	
	playerList.add_child(label)


remote func player_left(id):
	print_debug("player " + id + " left")
	players.erase(id)
