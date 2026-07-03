extends Node2D
const player_scene = preload("res://main/player.tscn")
var enet_peer = ENetMultiplayerPeer.new()
var my_player : player
var port = MultiplayerManagement.port
var join_code: String
@export var players : Dictionary = {}


func _ready() -> void:
	multiplayer.connection_failed.connect(on_connected_fail)
	multiplayer.server_disconnected.connect(on_server_disconnected)
	multiplayer.peer_disconnected.connect(on_player_disconnected)
	multiplayer.connected_to_server.connect(on_connected_to_server)
	
	if MultiplayerManagement.playing_multiplayer == true:
		if MultiplayerManagement.multiplayer_stats["ip"] == "host":
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


func host() -> void:
	var host_ip = "127.0.0.1"
	if MultiplayerManagement.upnp and MultiplayerManagement.upnp.query_external_address():
		host_ip = MultiplayerManagement.upnp.query_external_address()
	enet_peer.create_server(port)
	multiplayer.multiplayer_peer = enet_peer
	join_code = MultiplayerManagement.encode(host_ip)
	spawn_validated_players(multiplayer.get_unique_id(), MultiplayerManagement.multiplayer_stats["username"])
	multiplayer.peer_disconnected.connect(remove_player)
	MultiplayerManagement.upnp_setup()

	$CanvasLayer.show()
	$CanvasLayer/HBoxContainer/Label.text += join_code


func join(ip) -> void:
	if ip == "bulba.net": enet_peer.create_client("67.160.110.100", port)
	elif ip == "sawyer.net": 
		enet_peer.create_client("184.182.0.132", port)
	else: 
		enet_peer.create_client(ip, port)
	
	multiplayer.multiplayer_peer = enet_peer

func add_player(peer_id):
	my_player = get_node_or_null(str(peer_id))
	prints(players)

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
			print("Disconnect: Invalid Session ID")
			return
		spawn_validated_players.rpc(sender_id, client_username)

@rpc("any_peer") func reject_client():
	print("Connection rejected by server: Invalid Session ID.")
	MultiplayerManagement.playing_multiplayer = false
	
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
		
	get_tree().change_scene_to_file("res://main/title.tscn")

@rpc("any_peer", "call_local") func spawn_validated_players(id: int, username: String):
	var the_player = player_scene.instantiate()
	the_player.name = str(id)
	the_player.username = username
	add_child(the_player)
	players[id] = the_player
	if id == multiplayer.get_unique_id():
		my_player = the_player
		MultiplayerManagement.local_player = the_player.global_position
	
	the_player.update_username()
	
func _exit_tree() -> void:
	if MultiplayerManagement.playing_multiplayer == true:
		if multiplayer.is_server():
			pass
			# this is here for any save data nessesary
			
func _on_copy_pressed() -> void:
	DisplayServer.clipboard_set(join_code)

func on_connected_to_server():
	verify_session.rpc_id(1, MultiplayerManagement.multiplayer_stats["username"], MultiplayerManagement.session_id)
