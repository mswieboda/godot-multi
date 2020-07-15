extends Node

const DEFAULT_SERVER_IP = '127.0.0.1'
const DEFAULT_SERVER_PORT = 31400

onready var LOBBY_BASE_URL = Env.get("LOBBY_BASE_URL")


func clear_children(node : Node):
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
