extends VBoxContainer

onready var main = get_parent().get_node("main")
onready var lobbies = get_parent().get_node("lobbies")
onready var lobby = get_parent().get_node("lobby")
onready var popup = get_node("/root/menu/popup")

func _ready():
# warning-ignore:return_value_discarded
	Network.connect("server_created", self, "_on_server_created")
# warning-ignore:return_value_discarded
	Network.connect("server_joined", self, "_on_server_joined")


func _on_server_created():
	var http = HTTPRequest.new()
	add_child(http)
	http.connect("request_completed", self, "_on_create_request_completed")

	var data = { "name": "Real 1337 Lobby", "size": 13 }
	var headers = [
		"Content-Type: application/json",
		"GAME_KEY: " + Global.GAME_KEY
	]
	var json = JSON.print(data)
	print("json: " + json)
	var error = http.request(Global.LOBBY_BASE_URL + "/lobbies/create", headers, false, HTTPClient.METHOD_POST, json)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
	print("lobby create requested")


func _on_create_request_completed(result, _response_code, _headers, _body):
	print("lobby create request completed")
	if result != OK:
		push_error("An error occurred in the HTTP request result.")
		print("result: " + result)
		print("response_code: " + _response_code)
		print("_headers: " + _headers)
		print("_body" + _body)

	# TODO: pass this response's lobby ID somewhere globalish
	# so we can use it for start/end requests
	showLobby()


func _on_server_joined():
	showLobby()


func showLobby():
	hide()
	lobby.show()


func _on_create_gui_input(event : InputEvent):
	if (event.is_pressed()):
		popup.show_create()


func _on_join_gui_input(event : InputEvent):
	if (event.is_pressed()):
		hide()
		lobbies.show()
		lobbies.load_lobbies()


func _on_back_gui_input(event : InputEvent):
	if (event.is_pressed()):
		hide()
		main.show()
