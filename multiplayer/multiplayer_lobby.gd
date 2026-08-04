extends Node2D

var lobby_id : int = 0
var peer : SteamMultiplayerPeer
@export var player_scene : PackedScene

var is_host : bool = false
var is_joining: bool = false

func _ready() -> void:
	print("Steam init: ", Steam.steamInit(480, true))
	Steam.initRelayNetworkAccess()
	Steam.lobby_created.connect(on_lobby_created)
	Steam.lobby_joined.connect(on_lobby_joined)
	if MultiplayerManagement.host_pressed == true:
		host_lobby()
	if MultiplayerManagement.join_pressed == true:
		join_lobby(MultiplayerManagement.join_code)
func host_lobby():
	Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, 16)
	is_host = true

	
func on_lobby_created(result: int, lobby_id: int):
	if result == Steam.Result.RESULT_OK:
		self.lobby_id = lobby_id
		
		peer = SteamMultiplayerPeer.new()
		peer.server_relay = true
		peer.create_host()
		
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_connected.connect(add_player)
		multiplayer.peer_disconnected.connect(remove_player)
		add_player()
		$CanvasLayer/HBoxContainer/Label.text = "Join Code: " + str(lobby_id)
		print(lobby_id)

func join_lobby(lobby_id: int):
	is_joining = true
	Steam.joinLobby(lobby_id)

func on_lobby_joined(lobby_id: int, permissions: int, locked: bool, response: int):
	if !is_joining:
		return
	
	self.lobby_id = lobby_id
	peer = SteamMultiplayerPeer.new()
	peer.server_relay = true
	peer.create_client(Steam.getLobbyOwner(lobby_id))
	multiplayer.multiplayer_peer = peer

	is_joining = false
	MultiplayerManagement.join_pressed = false
	print("join")
	
func add_player(id: int = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)

func remove_player(id: int):
	if !self.has_node(str(id)):
		return
	
	self.get_node(str(id)).queue_free()
