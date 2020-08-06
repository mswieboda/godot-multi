extends Spatial

var players_ready : Array = []
var spawn_index = 0

func load_players(id):
	var playersNode = get_node("players")

	print("load!")
	print(Network.players)

	for player_id in Network.players:
		var info = Network.players[player_id]
		var player = preload("res://objs/player/player.tscn").instance()
		player.set_name(str(player_id))
		player.set_network_master(player_id)
		player.set_color(info.color)

		var spawn_xform = available_spawn()

		if spawn_xform:
			player.spawn(spawn_xform)
		else:
			print("no available spawns")

		playersNode.add_child(player)

		if id == player_id:
			player.enable_camera()

	if get_tree().is_network_server():
		ready(id)
	else:
		rpc_id(1, "ready", id)


func available_spawn():
	if spawn_index > $spawns.get_child_count():
		return null

	var spawn = $spawns.get_child(spawn_index)
	spawn_index += 1
	return spawn.get_global_transform()


remote func ready(id):
	if not get_tree().is_network_server():
		return

	players_ready.append(id)

	if players_ready.size() == Network.players.size():
		start()
		rpc("start")


remote func start():
	if get_tree().is_network_server():
		game_lobby_start()
	print("start!")


func game_lobby_start():
	var http = HTTPRequest.new()
	http.connect("request_completed", self, "_on_lobby_start_request_completed")
	add_child(http)

	var headers = ["GAME_KEY: " + Global.GAME_KEY]
	print("game_lobby_start POST: ", Global.LOBBY_BASE_URL + "/lobbies/" + str(Network.lobby_id) + "/start")
	var error = http.request(Global.LOBBY_BASE_URL + "/lobbies/" + str(Network.lobby_id) + "/start", headers, true, HTTPClient.METHOD_POST)
	if error != OK:
		push_error("An error occurred in the HTTP request.")


func _on_lobby_start_request_completed(result, response_code, _headers, body):
	print("game_lobby_start requested")
	if result != OK:
		print("game_lobby_start request error: ", response_code, " ", body.get_string_from_utf8())
		return

	print("body:", body.get_string_from_utf8())
