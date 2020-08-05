extends PopupPanel

onready var nameEdit = find_node("name")
onready var ipEdit = find_node("ip address")
onready var colorEdit = find_node("color picker")

var lobby


func show_create():
	find_node("join").hide()
	find_node("create").show()
	popup_centered_minsize()


func show_join(lobby_to_join):
	lobby = lobby_to_join
	find_node("join").show()
	find_node("create").hide()
	popup_centered_minsize()


func _on_popup_create_pressed():
	Network.create_server(nameEdit.text, colorEdit.color)
	hide()


func _on_popup_join_pressed():
	var player_info = { username = nameEdit.text, color = colorEdit.color}
	Network.join_server(lobby["host"], player_info)
	hide()


func _on_popup_back_pressed():
	hide()
