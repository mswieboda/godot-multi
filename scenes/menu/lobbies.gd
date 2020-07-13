extends VBoxContainer

const LOBBY_URL = "https://gd-multi-lobby.herokuapp.com"


func _ready():
# warning-ignore:return_value_discarded
	$HTTPRequest.connect("request_completed", self, "_on_request_completed")


func load_lobbies():
	$HTTPRequest.request(LOBBY_URL + "/lobbies")


func _on_request_completed(_result, _response_code, _headers, body):
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

