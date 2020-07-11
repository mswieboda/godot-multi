extends CanvasItem

const MAX_PLAYERS = 5

var players = {}
var self_player_info = { username = '' }

func _ready():
	get_tree().connect('connected_to_server', self, '_connected_to_server')
	get_tree().connect('network_peer_disconnected', self, '_network_peer_disconnected')
	get_tree().connect('server_disconnected', self, '_server_disconnected')
	get_tree().connect('connection_failed', self, '_connected_failed')


func create_server(username, color = Color.red):
	self_player_info = { username = username, color = color }
	var peer = NetworkedMultiplayerENet.new()
	
	print_debug("creating server")
	
	peer.create_server(Global.DEFAULT_SERVER_PORT, MAX_PLAYERS)
	get_tree().set_network_peer(peer)
	
	var play = get_parent().get_node("play")
	
	play.hide()
	show()
	
	player_connected(1, self_player_info)


func join_server(username, ip_address = Global.DEFAULT_SERVER_IP, color = Color.green):
	self_player_info = { username = username, color = color }
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

	if id == get_tree().get_network_unique_id():
		render_player_info(player_info)
		
		if get_tree().is_network_server():
			get_node("actions/start").show()

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
	
	players.erase(id)
	
	render_players_list()


func _server_disconnected():
	print_debug("_server_disconnected")
	
	get_tree().set_network_peer(null)
	
	players = {}
	render_players_list()
	hide()
	get_parent().get_node("main").show()


func _connection_failed():
	print_debug("_connection_failed")


func render_player_info(player_info : Dictionary):
	var name = get_node("info/name")
	var colorEdit = get_node("info/color picker")
	
	name.text = player_info.username
	name.set("custom_colors/font_color", player_info.color)
	colorEdit.color = player_info.color


func render_players_list():
	var players_list = get_node("players list")
	
	if (players_list):
		remove_child(players_list)
	
	players_list = VBoxContainer.new()
	players_list.set_name("players list")

	for player_id in players:
		var player_data = players[player_id]
		var label = Label.new()
		
		label.set_name(str(player_id))
		label.text = player_data.username
		
		if player_id == 1:
			label.text += " (host)"
		
		label.set("custom_colors/font_color", player_data.color)
		
		players_list.add_child(label)
	
	add_child(players_list)


remote func change_color(player_id, color : Color):
	players[player_id].color = color
	
	render_players_list()


func _on_color_picker_color_changed(color : Color):
	var player_id = get_tree().get_network_unique_id()
	change_color(player_id, color)
	rpc("change_color", player_id, color)	
	render_player_info(players[player_id])


func _on_leave_gui_input(event : InputEvent):
	if (event.is_pressed()):
		leave_lobby()


func _on_start_gui_input(event : InputEvent):
	if (event.is_pressed()):
		load_lobby()
		rpc("load_lobby")
		

remote func load_lobby():
	var id = get_tree().get_network_unique_id()
	var lobby = load("res://scenes/lobby/lobby.tscn").instance()
	
	lobby.load_players(id, players)
	
	get_tree().change_scene_to(lobby)
