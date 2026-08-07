extends Node2D

@export var labels: Array[Label]
@onready var interaction_area : InteractionArea = $InteractionArea
var players : Array
var cycle: bool = false
var map_cycle : bool = false

func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact():
	request_server_team_assignment.rpc_id(1)
	players = get_tree().get_nodes_in_group("player")
	print(players)
	await run_local_animation_cycle()
	MultiplayerManagement.mode = 1
	MultiplayerManagement.change_map(MultiplayerManagement.maps.pick_random())


@rpc("any_peer", "call_local", "reliable")
func request_server_team_assignment():
	if multiplayer.is_server():
		assign_teams()


func assign_teams():
	if !multiplayer.is_server():
		return
		
	var player_ids: Array = players
	randomize()
	player_ids.shuffle()
	var half = player_ids.size() / 2
	
	for i in range(player_ids.size()):
		var peer_id = player_ids[i]
		var team_tag = "nice"
		if i < half:
			team_tag = "naughty"
			
		sync_teams.rpc(peer_id, team_tag)
		
	start_global_cycle.rpc()

@rpc("any_peer", "call_local", "reliable")
func sync_teams(player_id: int, tag: String):
	labels[0].add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	labels[1].add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))

	if players.has(player_id):
		var player_node = players[player_id]
		if is_instance_valid(player_node):
			player_node.team = tag


@rpc("any_peer", "call_local", "reliable")
func start_global_cycle():
	if cycle: 
		return
	run_local_animation_cycle()


func run_local_animation_cycle():
	cycle = true
	var timer_length = 1.5
	var cycle_complete : bool = false
	
	var local_uid = multiplayer.get_unique_id()
	var my_team = MultiplayerManagement.my_team
	
	if players.has(local_uid) and is_instance_valid(players[local_uid]):
		my_team = players[local_uid].team
		
	while cycle:
		if timer_length <= 0.05:
			cycle = false
			cycle_complete = true
			break
			
		labels[0].show()
		labels[1].hide()
		timer_length -= 0.1
		await get_tree().create_timer(max(0.01, timer_length)).timeout
		
		if timer_length <= 0.05:
			cycle = false
			break
			
		labels[0].hide()
		labels[1].show()
		timer_length -= 0.1
		await get_tree().create_timer(max(0.01, timer_length)).timeout

	while map_cycle:
		pass

	if my_team == "naughty":
		labels[0].show()
		labels[1].hide()
		labels[0].add_theme_color_override("font_color", Color(0.812, 0.0, 0.0, 1.0))

	else:
		labels[0].hide()
		labels[1].show()
		labels[1].add_theme_color_override("font_color", Color(0.243, 0.669, 0.311, 1.0))
	
	if cycle_complete:
		await get_tree().create_timer(2).timeout
		map_cycle = true
	
