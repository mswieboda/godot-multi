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
	
	rpc_id(1, "ready", id)


func available_spawn():
	if spawn_index > $spawns.get_child_count():
		return null
		
	var spawn = $spawns.get_child(spawn_index)
	spawn_index += 1
	return spawn.get_global_transform()


remote func ready(id):
	assert(get_tree().is_network_server())
	assert(id in Network.players)
	assert(not id in players_ready)

	players_ready.append(id)

	if players_ready.size() == Network.players.size():
		rpc("start")


remote func start():
	print("start!")
