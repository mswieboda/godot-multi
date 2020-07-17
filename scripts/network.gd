extends Node

const MAX_PLAYERS = 5

var players = {}
var self_player_info = { username = '' }
var lobby_id

signal server_created
signal server_joined
signal server_player_joined
signal server_player_disconnected
signal server_leave
signal server_disconnected

func _ready():
# warning-ignore:return_value_discarded
	get_tree().connect('connected_to_server', self, '_connected_to_server')
# warning-ignore:return_value_discarded
	get_tree().connect('network_peer_disconnected', self, '_network_peer_disconnected')
# warning-ignore:return_value_discarded
	get_tree().connect('server_disconnected', self, '_server_disconnected')
# warning-ignore:return_value_discarded
	get_tree().connect('connection_failed', self, '_connection_failed')


func create_server(username, color = Color.red):
	self_player_info = { username = username, color = color }
	var peer = NetworkedMultiplayerENet.new()

	print_debug("creating server")

	peer.create_server(Global.DEFAULT_SERVER_PORT, MAX_PLAYERS)
	get_tree().set_network_peer(peer)

	emit_signal("server_created")

	player_connected(1, self_player_info)


func join_server(ip_address, player_info):
	ip_address = Global.DEFAULT_SERVER_IP
	print("join_server: " + ip_address + " " + str(player_info))
	self_player_info = player_info
	var peer = NetworkedMultiplayerENet.new()
	var error = peer.create_client(ip_address, Global.DEFAULT_SERVER_PORT)
	print(str(error))
	if error:
		print("join_server failed: " + str(error))
	get_tree().set_network_peer(peer)


func _connected_to_server():
	print("_connected_to_server")
	var id = get_tree().get_network_unique_id()

	emit_signal("server_joined")

	# tell server a new player connected
	rpc_id(1, 'new_player_connected', id, self_player_info)


remote func new_player_connected(id, player_info):
	if get_tree().is_network_server():
		# add all players for the newly connected player
		for player_id in players:
			rpc_id(id, "player_connected", player_id, players[player_id])

		game_lobby_joined(id, player_info)

		# tell all clients about the new player
		player_connected(id, player_info)
		rpc("player_connected", id, player_info)


remote func player_connected(id, player_info):
	players[id] = player_info
	print_debug("connected to server (" + str(id) + ")")

	emit_signal("server_player_joined", id, player_info)

	if get_tree().is_network_server():
		if id == 1:
			var name = "Real 1337 Lobby"
			var size = 13
			var data = { "name": name, "size": size }
			game_lobby_created(data)


func leave_lobby():
	var id = get_tree().get_network_unique_id()

	print_debug("leave_lobby")

	if not get_tree().is_network_server():
		_network_peer_disconnected(id)

	get_tree().set_network_peer(null)

	players = {}

	emit_signal("server_leave")

func _network_peer_disconnected(id):
	print_debug("disconnecting from server (" + str(id) + ")")

	if (!players.has(id)):
		return

	players.erase(id)

	emit_signal("server_player_disconnected")


func _server_disconnected():
	print_debug("_server_disconnected")

	get_tree().set_network_peer(null)

	players = {}

	emit_signal("server_disconnected")


func _connection_failed():
	print_debug("_connection_failed")


func render_player_info(player_info : Dictionary):
	var name = get_node("info/name")
	var colorEdit = get_node("info/color picker")

	name.text = player_info.username
	name.set("custom_colors/font_color", player_info.color)
	colorEdit.color = player_info.color


remote func change_color(player_id, color : Color):
	players[player_id].color = color

#	TODO: move to lobby.gd
#	render_players_list()


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
	var lobby = preload("res://scenes/lobby/lobby.tscn").instance()

	lobby.load_players(id, players)
	Scene.change(lobby)


func game_lobby_created(data):
	print("game_lobby_created request")
	var http = HTTPRequest.new()
	add_child(http)
	http.connect("request_completed", self, "_on_request_completed_game_lobby_create")

	var headers = [
		"Content-Type: application/json",
		"GAME_KEY: " + Global.GAME_KEY
	]
	var json = JSON.print(data)
	print("json: " + json)
	var error = http.request(Global.LOBBY_BASE_URL + "/lobbies/create", headers, false, HTTPClient.METHOD_POST, json)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
	print("game_lobby_create requested")


func _on_request_completed_game_lobby_create(result, _response_code, _headers, body):
	print("request completed game_lobby_create")
	if result != OK:
		push_error("An error occurred in the HTTP request result.")
		print("result: " + result)
		print("response_code: " + _response_code)
		print("_headers: " + _headers)
		print("_body" + body)
		return

	var json = JSON.parse(body.get_string_from_utf8())
	lobby_id = json.result["id"]

	print("set lobby_id: " + str(lobby_id))


func game_lobby_joined(_id, _player_info):
	print("game_lobby_joined request")
	print(str(lobby_id))
	var http = HTTPRequest.new()
	add_child(http)

	var headers = ["GAME_KEY: " + Global.GAME_KEY]
	var error = http.request(Global.LOBBY_BASE_URL + "/lobbies/" + str(lobby_id) + "/join", headers)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
	print("game_lobby_join requested")
