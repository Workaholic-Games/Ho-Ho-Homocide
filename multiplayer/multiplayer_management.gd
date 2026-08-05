extends Node

var host_pressed : bool = false
var join_pressed : bool = false
var is_playing : bool = false

var join_code : int = 0

var username : String = ""

var current_map: Node = null
var maps : Array = [
	"res://Cookie Crumble.tscn",
]


func change_map(map_path: String):
	if current_map:
		current_map.queue_free()
		await current_map.tree_exited
	
	var map_resource = load(map_path)
	if map_resource:
		current_map = map_resource.instantiate()
		get_node("/root/MultiplayerMain/Map").add_child(current_map)
	else:
		print("Failed to load map: ", map_path)
