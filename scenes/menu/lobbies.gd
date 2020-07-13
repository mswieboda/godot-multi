extends VBoxContainer

const LOBBY_URL = "https://gd-multi-lobby.herokuapp.com"

func _ready():
	$HTTPRequest.connect("request_completed", self, "_on_request_completed")

func load_lobbies():
	$HTTPRequest.request(LOBBY_URL + "/lobbies")

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var lobbies = json.result
	var lobbiesNode = get_node("lobbies")
	
	for lobby in lobbies:
		var label = Label.new()
		label.text = lobby["name"]
		lobbiesNode.add_child(label)
