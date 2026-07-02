extends Node2D
const player_scene = preload("res://main/player.tscn")
const port = 9998
var enet_peer = ENetMultiplayerPeer.new()
var my_player : player
var public_ip : String = ""
@export var players : Dictionary = {}


func _ready() -> void:
	multiplayer.connection_failed.connect(on_connected_fail)
	multiplayer.server_disconnected.connect(on_server_disconnected)
	multiplayer.peer_disconnected.connect(on_player_disconnected)
	
	if MultiplayerManagement.playing_multiplayer == true:
		if MultiplayerManagement.multiplayer_stats["ip"] == "host":
			host()
		else:
			MultiplayerManagement.decode()
			join(MultiplayerManagement.multiplayer_stats["ip"])
	else:
		var the_player = player_scene.instantiate()
		the_player.name = str(multiplayer.get_unique_id())
		the_player.username = MultiplayerManagement.multiplayer_stats["username"]
		add_child(the_player)


func host() -> void:
	enet_peer.create_server(port)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	add_player(multiplayer.get_unique_id())
	upnp_setup()


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

func upnp_setup():
	var upnp = UPNP.new()
	
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Discover Failed! Error %s" % discover_result)
	
	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
		"UPNP Invalid Gateway!")

	var map_result = upnp.add_port_mapping(port)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Port Mapping Failed! Error %s" % map_result)
	
	print("Success!")
	
	public_ip = upnp.query_external_address()
	print("IP is: " + str(public_ip))
	var ip_segments = public_ip.split(".")
	var raw_bytes = PackedByteArray()
	for segment in ip_segments:
		raw_bytes.append(segment.to_int())
	
	var encoded_session_key: String = Marshalls.raw_to_base64(raw_bytes)
	encoded_session_key = encoded_session_key.replace("=", "")
	print("Encoded: " + encoded_session_key)

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
			

	
