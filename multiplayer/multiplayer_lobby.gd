extends Node2D

@onready var http = $HTTPRequest

const player_scene = preload("res://main/player.tscn")
var enet_peer = ENetMultiplayerPeer.new()
var my_player : player
var port = MultiplayerManagement.port
var join_code: String
var players = MultiplayerManagement.players
var host_ip = "127.0.0.1"


func _ready() -> void:
	http.request_completed.connect(on_request_completed)
	multiplayer.connection_failed.connect(on_connected_fail)
	multiplayer.server_disconnected.connect(on_server_disconnected)
	multiplayer.peer_disconnected.connect(on_player_disconnected)
	multiplayer.connected_to_server.connect(on_connected_to_server)
	
	child_entered_tree.connect(func(node):
		if node.is_in_group("players") or node.name.to_int() > 0:
			setup_local_player(node.name.to_int(), node)
			print("player_added")
	)
	
	if MultiplayerManagement.playing_multiplayer == true:
		if MultiplayerManagement.multiplayer_stats["ip"] == "host":
			http.request("https://api.ipify.org/")
			await http.request_completed
			host()
		else:
			var decoded_result = MultiplayerManagement.decode(MultiplayerManagement.multiplayer_stats["ip"])
			if decoded_result.is_empty() or !"," in decoded_result:
				print("Connection failed: Invalid code")
				get_tree().change_scene_to_file("res://main/title.tscn")
				return
			else:
				var split = decoded_result.split(",")
				MultiplayerManagement.session_id = split[1].to_int()
				join(split[0])
				
	else:
		var the_player = player_scene.instantiate()
		the_player.name = str(multiplayer.get_unique_id())
		the_player.username = MultiplayerManagement.multiplayer_stats["username"]
		add_child(the_player)

func on_request_completed(_result, response_code, _headers, body):
	if response_code == 200:
		host_ip = body.get_string_from_utf8()
		print(host_ip)

func host() -> void:
	#MultiplayerManagement.upnp_setup()
	#if MultiplayerManagement.upnp and MultiplayerManagement.upnp.query_external_address():
		#host_ip = MultiplayerManagement.upnp.query_external_address()
	enet_peer.create_server(port)
	multiplayer.multiplayer_peer = enet_peer
	join_code = MultiplayerManagement.encode(host_ip)
	
	server_spawn_player(multiplayer.get_unique_id(), MultiplayerManagement.multiplayer_stats["username"])
	multiplayer.peer_disconnected.connect(remove_player)

	$CanvasLayer/HBoxContainer.show()
	$CanvasLayer/HBoxContainer/Label.text += join_code
	print(players)

func join(ip) -> void:
	if ip == "bulba.net": enet_peer.create_client("67.160.110.100", port)
	elif ip == "sawyer.net": 
		enet_peer.create_client("184.182.0.132", port)
	else: 
		enet_peer.create_client(ip, port)
	
	multiplayer.multiplayer_peer = enet_peer
	print(ip)

func remove_player(peer_id):
	var the_player = get_node_or_null(str(peer_id))
	if the_player:
		the_player.queue_free()
	if players.has(peer_id):
		players.erase(peer_id)

func on_connected_fail():
	MultiplayerManagement.playing_multiplayer = false
	get_tree().change_scene_to_file("res://main/title.tscn")

func on_server_disconnected():
	MultiplayerManagement.playing_multiplayer = false
	if is_inside_tree() and get_tree() != null:
		get_tree().change_scene_to_file("res://main/title.tscn")

func on_player_disconnected(id):
	remove_player(id)

@rpc("any_peer") func verify_session(client_username: String, client_session_id: int):
	if multiplayer.is_server():
		var sender_id = multiplayer.get_remote_sender_id()
		if client_session_id != MultiplayerManagement.session_id:
			reject_client.rpc_id(sender_id)
			return

		server_spawn_player(sender_id, client_username)
		

@rpc("any_peer") func reject_client():
	print("Connection rejected by server: Invalid Session ID.")
	MultiplayerManagement.playing_multiplayer = false
	
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
		
	get_tree().change_scene_to_file("res://main/title.tscn")

@rpc("any_peer") func change_username(id):
	get_node(str(id)).username = MultiplayerManagement.multiplayer_stats["username"]
	get_node(str(id)).update_username()

func server_spawn_player(id: int, username: String):
	var the_player = player_scene.instantiate()
	the_player.name = str(id)
	the_player.username = username
	add_child(the_player)
	change_username.rpc(id)

func setup_local_player(id: int, the_player: Node):
	players[id] = the_player
	if id == multiplayer.get_unique_id():
		my_player = the_player
		MultiplayerManagement.local_player = the_player
	
	await get_tree().create_timer(0.1).timeout
	if is_instance_valid(the_player):
		print("The Player Username ", the_player.username)

func _on_copy_pressed() -> void:
	DisplayServer.clipboard_set(join_code)

func on_connected_to_server():
	await get_tree().physics_frame
	verify_session.rpc_id(1, MultiplayerManagement.multiplayer_stats["username"], MultiplayerManagement.session_id)
	print("connection_username: ", MultiplayerManagement.multiplayer_stats["username"])
