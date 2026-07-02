extends Node2D
const player_scene = preload("res://main/player.tscn")
var enet_peer = ENetMultiplayerPeer.new()
var my_player : player
var port = MultiplayerManagement.port
@export var players : Dictionary = {}


func _ready() -> void:
	multiplayer.connection_failed.connect(on_connected_fail)
	multiplayer.server_disconnected.connect(on_server_disconnected)
	multiplayer.peer_disconnected.connect(on_player_disconnected)
	
	if MultiplayerManagement.playing_multiplayer == true:
		if MultiplayerManagement.multiplayer_stats["ip"] == "host":
			host()
		else:
			var target = MultiplayerManagement.	decode(MultiplayerManagement.multiplayer_stats["ip"])
			join(target)
	else:
		var the_player = player_scene.instantiate()
		the_player.name = str(multiplayer.get_unique_id())
		the_player.username = MultiplayerManagement.multiplayer_stats["username"]
		the_player.position = Vector2(336.0, 192.0)
		add_child(the_player)


func host() -> void:
	enet_peer.create_server(port)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	add_player(multiplayer.get_unique_id())
	MultiplayerManagement.upnp_setup()
	var host_ip = "127.0.0.1"
	if MultiplayerManagement.upnp and MultiplayerManagement.upnp.query_external_address():
		host_ip = MultiplayerManagement.upnp.query_external_address()
	var join_code = MultiplayerManagement.encode(host_ip)
	print("hosted ", join_code)


func join(ip) -> void:
	if ip == "bulba.net": enet_peer.create_client("67.160.110.100", port)
	elif ip == "sawyer.net": 
		enet_peer.create_client("184.182.0.132", port)
	else: 
		enet_peer.create_client(ip, port)
	
	multiplayer.multiplayer_peer = enet_peer

func add_player(peer_id):
	var the_player = player_scene.instantiate()
	the_player.name = str(peer_id)
	the_player.username = MultiplayerManagement.multiplayer_stats["username"]
	add_child(the_player)
	change_username.rpc(peer_id)
	my_player = get_node_or_null(str(peer_id))
	players.get_or_add(the_player.username)

func remove_player(peer_id):
	var the_player = get_node_or_null(str(peer_id))
	if the_player:
		the_player.queue_free()

func on_connected_fail():
	MultiplayerManagement.playing_multiplayer = false
	get_tree().change_scene_to_file("res://main/title.tscn")

func on_server_disconnected():
	MultiplayerManagement.playing_multiplayer = false
	get_tree().change_scene_to_file("res://main/title.tscn")

func on_player_disconnected(id):
	remove_player(id)

@rpc("any_peer") func change_username(id):
	get_node(str(id)).username = MultiplayerManagement.multiplayer_stats["username"]
	get_node(str(id)).update_username()

	
func _exit_tree() -> void:
	if MultiplayerManagement.playing_multiplayer == true:
		if multiplayer.is_server():
			pass
			# this is here for any save data nessesary
			

	
