extends Node

const SAVE_DIR = "user://Ho Ho Homicide/"
@export var save_file_name: String = "PlayerData.tres"

var player_data: PlayerData = PlayerData.new()

func _ready() -> void:
	verify_save_directory(SAVE_DIR)

func verify_save_directory(path: String) -> void:
	if not DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_absolute(path)

func load_data() -> void:
	var full_path = SAVE_DIR + save_file_name
	
	if FileAccess.file_exists(full_path):
		var loaded_res = ResourceLoader.load(full_path)
		if loaded_res is PlayerData:
			player_data = loaded_res.duplicate(true)
			print("Data successfully loaded!")
	else:
		print("No save file found. Creating a fresh PlayerData profile.")
		player_data = PlayerData.new()
		save_data()

func save_data() -> void:
	var full_path = SAVE_DIR + save_file_name
	var error = ResourceSaver.save(player_data, full_path)
	
	if error == OK:
		print("Data successfully saved to: ", full_path)
	else:
		print("Failed to save data. Error code: ", error)
