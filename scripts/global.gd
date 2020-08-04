extends Node

# Networking
const DEFAULT_SERVER_IP = '127.0.0.1'
const DEFAULT_SERVER_PORT = 31400

# RayCast hit, extra height for texture layering
const HEIGHT_LAYERING_RATIO = 0.01

onready var LOBBY_BASE_URL = Env.get("LOBBY_BASE_URL")
onready var GAME_KEY = Env.get("GAME_KEY")

func clear_children(node : Node):
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()


func perpendicular_basis_from_normal(normal : Vector3):
	# Find the axis with the smallest component
	var min_ind = 0
	var min_axis = abs(normal.x)

	if abs(normal.y) < min_axis:
		min_ind = 1
		min_axis = abs(normal.y)
	if abs(normal.z) < min_axis:
			min_ind = 2

	var right

	# Leave the minimum axis in its place,
	# swap the other two to get a vector perpendicular to the normal vector
	if min_ind == 0:
		right = Vector3(normal.x, -normal.z, normal.y)
	elif min_ind == 1:
		right = Vector3(-normal.z, normal.y, normal.x)
	elif min_ind == 2:
		right = Vector3(-normal.y, normal.x, normal.z)

	var up = normal.cross(right)
	return Basis(right, up, normal)
