extends "res://scenes/menu/menu.gd"

const Text = preload("res://objs/text/text.tscn")

onready var lobby = get_parent().get_node("lobby")
onready var popup = get_node("/root/menu/popup")
onready var multi = get_parent().get_node("multi")


func _ready():
# warning-ignore:return_value_discarded
	Network.connect("server_joined", self, "_on_server_joined")


func load_lobbies():
	var http = HTTPRequest.new()
	add_child(http)
	http.connect("request_completed", self, "_on_lobbies_request_completed")

	var headers = ["GAME_KEY: " + Global.GAME_KEY]
	var error = http.request(Global.LOBBY_BASE_URL + "/lobbies", headers)
	if error != OK:
		push_error("An error occurred in the HTTP request.")


func _on_lobbies_request_completed(result, response_code, _headers, body):
	if result != OK or response_code != 200:
		print("lobbies request error: " + body.get_string_from_utf8())
		return

	var json = JSON.parse(body.get_string_from_utf8())
	var lobbies = json.result
	var lobbiesNode = get_node("lobbies")

	Global.clear_children(lobbiesNode)

	for lobby_data in lobbies:
		var label = Text.instance()
		label.text = lobby["name"]
		label.set_font_size(16)
		lobbiesNode.add_child(label)
		label.connect("gui_input", self, "_on_lobby_gui_input", [lobby_data])


func _on_lobby_gui_input(event, lobby_data):
	if event.is_pressed():
		popup.show_join(lobby_data)


func _on_back_gui_input(event):
	is_pressed_go_to(event, multi)


func _on_server_joined():
	print("_on_server_joined")
	go_to(lobby)
