extends CanvasItem

const DEFAULT_IP = '127.0.0.1'
const DEFAULT_PORT = 31400
const MAX_PLAYERS = 5

var players = {}
var self_player_info = { username = '' }

func _ready():
	get_tree().connect('network_peer_disconnected', self, '_network_peer_disconnected')
	get_tree().connect('connected_to_server', self, '_connected_to_server')


func create_server(username):
	self_player_info = { username = username }
	var peer = NetworkedMultiplayerENet.new()
	
	print_debug("creating server")
	
	peer.create_server(DEFAULT_PORT, MAX_PLAYERS)
	get_tree().set_network_peer(peer)
	
	player_connected(1, self_player_info)


func join_server(username):
	self_player_info = { username = username }
	var peer = NetworkedMultiplayerENet.new()
	
	print_debug("joining server (" + username + ")")
	
	peer.create_client(DEFAULT_IP, DEFAULT_PORT)
	get_tree().set_network_peer(peer)


func _connected_to_server():
	var id = get_tree().get_network_unique_id()
	
	player_connected(id, self_player_info)	
	rpc('player_connected', id, self_player_info)	


remote func player_connected(id, player_info):
	players[id] = player_info
	print_debug("connected to server (" + str(id) + ")")

	var play = get_parent().get_node("play")
	
	play.hide()
	show()

	var label = Label.new()
	
	label.set_name(str(id))
	label.text = player_info.username
	
	add_child(label)


func leave_lobby():
	var id = get_tree().get_network_unique_id()
	player_disconnected(id)
	rpc("player_disconnected", id)


remote func player_disconnected(id):
	if (!players.has(id)):
		return
	
	var player_info = players[id]
	players.erase(id)
	
	var player = get_node(str(id))
	remove_child(player)
