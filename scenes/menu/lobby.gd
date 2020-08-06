extends "res://scenes/menu/menu.gd"

onready var main = get_parent().get_node("main")
onready var players_list = get_node("players list")
const Text = preload("res://objs/text/text.tscn")


func _ready():
# warning-ignore:return_value_discarded
	Network.connect("server_player_joined", self, "_on_server_player_joined")
# warning-ignore:return_value_discarded
	Network.connect("server_player_disconnected", self, "_on_server_player_disconnected")
# warning-ignore:return_value_discarded
	Network.connect("server_disconnected", self, "_on_server_disconnected")


func _on_server_player_joined(id, player_info):
	if id == get_tree().get_network_unique_id():
		render_player_info(player_info)

		if get_tree().is_network_server():
			get_node("actions/start").show()

	render_players_list()


func _on_server_player_disconnected():
	render_players_list()


func _on_server_disconnected():
	render_players_list()
	go_to(main)


func render_player_info(player_info : Dictionary):
	var name = get_node("info/name")
	var colorEdit = get_node("info/color picker")

	name.text = player_info.username
	name.set_color(player_info.color)
	colorEdit.color = player_info.color


func render_players_list():
	Global.clear_children(players_list)

	for player_id in Network.players:
		var player_data = Network.players[player_id]
		var label = Text.instance()

		label.set_name(str(player_id))
		label.text = player_data.username

		if player_id == 1:
			label.text += " (host)"

		label.set_font_size(23)
		label.set_hoverable(false)
		label.set_color(player_data.color)

		players_list.add_child(label)


remote func change_color(player_id, color : Color):
	Network.players[player_id].color = color

	render_players_list()


func _on_color_picker_color_changed(color : Color):
	var player_id = get_tree().get_network_unique_id()
	change_color(player_id, color)
	rpc("change_color", player_id, color)
	render_player_info(Network.players[player_id])


func _on_leave_gui_input(event : InputEvent):
	if event.is_pressed():
		Network.leave_lobby()


func _on_start_gui_input(event : InputEvent):
	if event.is_pressed():
		load_game()
		rpc("load_game")


remote func load_game():
	var id = get_tree().get_network_unique_id()
	var game = preload("res://scenes/multi/multi.tscn").instance()
	
	Scene.change(game)
	game.load_players(id)
