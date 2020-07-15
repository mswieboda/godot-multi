extends VBoxContainer

onready var LOBBY_BASE_URL = Env.get("LOBBY_BASE_URL")

func load_lobbies():
	print("load_lobbies!")
	var http = HTTPRequest.new()
	add_child(http)
	http.connect("request_completed", self, "_lobbies_request_completed")

	var error = http.request(LOBBY_BASE_URL + "/lobbies")
	if error != OK:
		push_error("An error occurred in the HTTP request.")
	print("load_lobbies requested")


func _lobbies_request_completed(_result, _response_code, _headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var lobbies = json.result
	var lobbiesNode = get_node("lobbies")
	
	Global.clear_children(lobbiesNode)
	
	for lobby in lobbies:
		var label = Label.new()
		label.text = lobby["name"]
		lobbiesNode.add_child(label)


func _on_back_gui_input(event):
	if event.is_pressed():
		hide()
		get_parent().get_node("play menu").show()

