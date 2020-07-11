extends Spatial

var players_ready = []

func load_players(id):
	var playersNode = get_node("players")

	print("load!")
	print(Network.players)
	
	for p in Network.players:
		var player = preload("res://scenes/player.tscn").instance()
		player.set_name(str(p))
		player.set_network_master(p)
		playersNode.add_child(player)
	
	rpc_id(1, "ready", id)


remote func ready(id):
	assert(get_tree().is_network_server())
	assert(id in Network.players)
	assert(not id in players_ready)

	players_ready.append(id)

	if players_ready.size() == Network.players.size():
		rpc("start")


remote func start():
	print("start!")
