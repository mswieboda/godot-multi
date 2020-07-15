extends VBoxContainer

const Text = preload("res://objs/text/text.tscn")

func load_lobbies():
	print("load_lobbies!")
	var http = HTTPRequest.new()
	add_child(http)
	http.connect("request_completed", self, "_on_lobbies_request_completed")

	var error = http.request(Global.LOBBY_BASE_URL + "/lobbies")
	if error != OK:
		push_error("An error occurred in the HTTP request.")
	print("load_lobbies requested: " + Global.LOBBY_BASE_URL + "/lobbies")


func _on_lobbies_request_completed(_result, _response_code, _headers, body):
	print("_lobbies_request_completed")
	var json = JSON.parse(body.get_string_from_utf8())
	var lobbies = json.result
	var lobbiesNode = get_node("lobbies")

	Global.clear_children(lobbiesNode)

	for lobby in lobbies:
		var label = Text.instance()
		label.text = lobby["name"]
		label.set_font_size(16)
		lobbiesNode.add_child(label)
		label.connect("gui_input", self, "_on_lobby_gui_input", [lobby])


func _on_lobby_gui_input(event, lobby):
	if event.is_pressed():
		join_lobby(lobby)


func _on_back_gui_input(event):
	if event.is_pressed():
		hide()
		get_parent().get_node("play menu").show()


func join_lobby(lobby):
	print("join_lobbies!")
	var http = HTTPRequest.new()
	add_child(http)
	http.connect("request_completed", self, "_on_join_request_completed", [lobby])

	var error = http.request(Global.LOBBY_BASE_URL + "/lobbies/" + str(lobby["id"]) + "/join")
	if error != OK:
		push_error("An error occurred in the HTTP request.")
	print("join_lobbies requested")


func _on_join_request_completed(result, _response_code, _headers, _body, lobby):
	print("join_lobbies completed")
	if result != OK:
		push_error("An error occurred in the HTTP request result.")

	var player_info = { username = "matt_client", color = Color.green }
	Network.join_server(lobby["host"], player_info)

	pass
