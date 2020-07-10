extends CanvasItem

const MAX_PLAYERS = 5

var players = {}
var self_player_info = { username = '' }

func _ready():
	get_tree().connect('connected_to_server', self, '_connected_to_server')
	get_tree().connect('network_peer_disconnected', self, '_network_peer_disconnected')
	get_tree().connect('server_disconnected', self, '_server_disconnected')
	get_tree().connect('connection_failed', self, '_connected_failed')


func create_server(username):
	self_player_info = { username = username }
	var peer = NetworkedMultiplayerENet.new()
	
	print_debug("creating server")
	
	peer.create_server(Global.DEFAULT_SERVER_PORT, MAX_PLAYERS)
	get_tree().set_network_peer(peer)
	
	var play = get_parent().get_node("play")
	
	play.hide()
	show()
	
	player_connected(1, self_player_info)


func join_server(username, ip_address = Global.DEFAULT_SERVER_IP):
	self_player_info = { username = username }
	var peer = NetworkedMultiplayerENet.new()
	
	print_debug("joining server " + ip_address + ": " + username)
	
	peer.create_client(ip_address, Global.DEFAULT_SERVER_PORT)
	get_tree().set_network_peer(peer)


func _connected_to_server():
	var id = get_tree().get_network_unique_id()
	var play = get_parent().get_node("play")
	
	play.hide()
	show()
	
#	player_connected(id, self_player_info)
	# tell server a new player connected
	rpc_id(1, 'new_player_connected', id, self_player_info)	


remote func new_player_connected(id, player_info):
	if get_tree().is_network_server():
		# add all players for the newly connected player
		for player_id in players:
			rpc_id(id, "player_connected", player_id, players[player_id])
			
		# tell all clients about the new player
		player_connected(id, player_info)
		rpc("player_connected", id, player_info)


remote func player_connected(id, player_info):
	players[id] = player_info
	print_debug("connected to server (" + str(id) + ")")

	render_players_list()


func leave_lobby():
	var id = get_tree().get_network_unique_id()
	
	print_debug("leave_lobby")
	
	get_tree().set_network_peer(null)
	_network_peer_disconnected(id)
	
	players = {}
	render_players_list()
	hide()
	get_parent().get_node("main").show()

func _network_peer_disconnected(id):
	print_debug("disconnecting from server (" + str(id) + ")")
	
	player_disconnected(id)
	rpc("player_disconnected", id)
	
remote func player_disconnected(id):
	if (!players.has(id)):
		return
	
	var player_info = players[id]
	players.erase(id)
	
	render_players_list()


func render_players_list():
	var players_list = get_node("players list")
	
	if (players_list):
		remove_child(players_list)
	
	players_list = VBoxContainer.new()
	players_list.set_name("players list")

	for player_id in players:
		var label = Label.new()
		
		label.set_name(str(player_id))
		label.text = players[player_id].username
		
		players_list.add_child(label)
	
	add_child(players_list)


func _server_disconnected():
	print_debug("_server_disconnected")
	
	get_tree().set_network_peer(null)
	
	players = {}
	render_players_list()
	hide()
	get_parent().get_node("main").show()


func _connection_failed():
	print_debug("_connection_failed")