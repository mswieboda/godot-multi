extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	print("ready!")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func load_players(id, players):
	var playersNode = get_node("players")

	print("load!")
	print(players)
	
	for p in players:
		var player = preload("res://scenes/player.tscn").instance()
		player.set_name(str(p))
		player.set_network_master(p)
		playersNode.add_child(player)
	
	# Tell server (remember, server is always ID=1) that this peer is done pre-configuring.
	rpc_id(1, "start", id)

remote func start(id):
	print("start! id: " + str(id))
