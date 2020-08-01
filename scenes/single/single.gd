extends Spatial

var players_ready : Array = []
var spawn_index = 0

func start(player_info):
	var player = preload("res://objs/player/player.tscn").instance()
		
	player.set_name("player")
	player.set_color(player_info.color)

	$players.add_child(player)
	player.enable_camera()

	var spawn_xform = available_spawn()

	if spawn_xform:
		player.spawn(spawn_xform)
	else:
		print("no available spawns")

	print("start!")


func available_spawn():
	if spawn_index > $spawns.get_child_count():
		return null

	var spawn = $spawns.get_child(spawn_index)
	spawn_index += 1
	return spawn.get_global_transform()

