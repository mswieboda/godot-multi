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

	get_tree().set_auto_accept_quit(false)


func _notification(notification):
	if notification == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		print("_notification MainLoop.NOTIFICATION_WM_QUIT_REQUEST (quitting)")
		var peer : NetworkedMultiplayerENet = get_tree().network_peer
		if peer:
			if get_tree().is_network_server():
				print("fire off game_lobby_ended")
				game_lobby_ended_on_quit()
			print("close connection")
			peer.close_connection()
		print("quit")
		get_tree().quit()


func create_server(username, color = Color.red):
	self_player_info = { username = username, color = color }
	var peer = NetworkedMultiplayerENet.new()

	print_debug("creating server")

	peer.create_server(Global.DEFAULT_SERVER_PORT, MAX_PLAYERS)
	get_tree().set_network_peer(peer)

	emit_signal("server_created")

	player_connected(1, self_player_info)


func join_server(ip_address, player_info):
	print("join_server: " + ip_address + " " + str(player_info))
	self_player_info = player_info
	var peer = NetworkedMultiplayerENet.new()
	var error = peer.create_client(ip_address, Global.DEFAULT_SERVER_PORT)

	if error:
		print("join_server failed: ", error)
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
	print_debug("leave_lobby")
	var peer : NetworkedMultiplayerENet = get_tree().network_peer

	if peer:
		if get_tree().is_network_server():
			game_lobby_ended()

		peer.close_connection()
		get_tree().set_network_peer(null)

	players.clear()

	emit_signal("server_disconnected")


func _network_peer_disconnected(id):
	print_debug("disconnecting from server (" + str(id) + ")")

	if (!players.has(id)):
		return

	players.erase(id)

	emit_signal("server_player_disconnected")


func _server_disconnected():
	print_debug("_server_disconnected")
	players.clear()
	emit_signal("server_disconnected")


func _connection_failed():
	print_debug("_connection_failed")


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
		print("_body" + body.get_string_from_utf8())
		return

	var json = JSON.parse(body.get_string_from_utf8())
	lobby_id = json.result["id"]
	print("request completed game_lobby_create lobby_id: ", lobby_id)


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


func game_lobby_ended_on_quit():
	var headers = [
		"Content-Type: application/json",
		"GAME_KEY: " + Global.GAME_KEY
	]
	var response = Web.delete(Global.LOBBY_BASE_URL, "lobbies/" + str(lobby_id) + "/end", headers)
	print("game_lobby_ended response: ", response)


func game_lobby_ended():
	print("game_lobby_ended request")
	var http = HTTPRequest.new()
	add_child(http)
	http.connect("request_completed", self, "_on_request_completed_game_lobby_end")

	var headers = [
		"Content-Type: application/json",
		"GAME_KEY: " + Global.GAME_KEY
	]
	print("game_lobby_end DELETE: ", Global.LOBBY_BASE_URL + "/lobbies/" + str(lobby_id) + "/end")
	var error = http.request(Global.LOBBY_BASE_URL + "/lobbies/" + str(lobby_id) + "/end", headers, true, HTTPClient.METHOD_DELETE)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
	print("game_lobby_end requested")


func _on_request_completed_game_lobby_end(result, _response_code, _headers, _body):
	print("request completed game_lobby_end:\n", _response_code, "\n", _body.get_string_from_utf8())
	if result != OK:
		push_error("An error occurred in the HTTP request result.")
		print("result: " + result)
		print("response_code: " + _response_code)
		print("_headers: " + _headers)
		print("_body" + _body)
		return

	lobby_id = null
