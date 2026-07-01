extends TextureButton

var house_level_data: LevelData

func _ready() -> void:
	house_level_data = LevelData.new()
	house_level_data.difficulty = randi_range(1, 5)
	house_level_data.scale_hazards()
	$Difficulty.text = "Difficulty: " + str(house_level_data.difficulty)
	
	pressed.connect(_on_house_pressed)

func _on_house_pressed() -> void:
	CurrentLevelData.current_level_data = house_level_data
	print("Loading house with difficulty: ", house_level_data.difficulty)
	print("Active hazards: ", house_level_data.active_hazards)
	
	get_tree().change_scene_to_file("res://levels/house.tscn")
