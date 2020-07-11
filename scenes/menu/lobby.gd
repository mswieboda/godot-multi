extends CanvasItem


onready var main = get_parent().get_node("main")


func _ready():
	Network.connect("server_player_joined", self, "_on_server_player_joined")
	Network.connect("server_player_disconnected", self, "_on_server_player_disconnected")
	Network.connect("server_leave", self, "_on_server_leave")
	Network.connect("server_disconnected", self, "_on_server_disconnected")


func _on_server_player_joined(id, player_info):
	if id == get_tree().get_network_unique_id():
		render_player_info(player_info)

		if get_tree().is_network_server():
			get_node("actions/start").show()

	render_players_list()


func _on_server_player_disconnected():
	render_players_list()


func _on_server_leave():
	render_players_list()
	show_main()


func _on_server_disconnected():
	render_players_list()
	show_main()


func show_main():
	hide()
	main.show()

func render_player_info(player_info : Dictionary):
	var name = get_node("info/name")
	var colorEdit = get_node("info/color picker")
	
	name.text = player_info.username
	name.set("custom_colors/font_color", player_info.color)
	colorEdit.color = player_info.color


func render_players_list():
	var players_list = get_node("players list")
	
	if (players_list):
		remove_child(players_list)
	
	players_list = VBoxContainer.new()
	players_list.set_name("players list")

	for player_id in Network.players:
		var player_data = Network.players[player_id]
		var label = Label.new()
		
		label.set_name(str(player_id))
		label.text = player_data.username
		
		if player_id == 1:
			label.text += " (host)"
		
		label.set("custom_colors/font_color", player_data.color)
		
		players_list.add_child(label)
	
	add_child(players_list)


remote func change_color(player_id, color : Color):
	Network.players[player_id].color = color
	
	render_players_list()


func _on_color_picker_color_changed(color : Color):
	var player_id = get_tree().get_network_unique_id()
	change_color(player_id, color)
	rpc("change_color", player_id, color)	
	render_player_info(Network.players[player_id])


func _on_leave_gui_input(event : InputEvent):
	if (event.is_pressed()):
		Network.leave_lobby()


func _on_start_gui_input(event : InputEvent):
	if (event.is_pressed()):
		load_lobby()
		rpc("load_lobby")
		

remote func load_lobby():
	var id = get_tree().get_network_unique_id()
	var lobby = preload("res://scenes/lobby/lobby.tscn").instance()

	lobby.load_players(id)
	Scene.change(lobby)
