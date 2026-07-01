extends Node2D

@export var my_level_data: LevelData = LevelData.new()
@export var ui : CanvasLayer
@onready var interaction_area : InteractionArea = $InteractionArea
@export var labels : Array[Node]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")
	
	if my_level_data:
		my_level_data = my_level_data.duplicate()
		randomize()
		my_level_data.difficulty = randi_range(1, 5)
		my_level_data.scale_hazards()
		print(my_level_data.active_hazards)
func _on_interact() -> void:
	ui.show()

func _on_close_button_pressed() -> void:
	$AudioStreamPlayer2D.play(0.56)
	ui.hide()

func _on_house_pressed() -> void:
	CurrentLevelData.current_level_data = my_level_data
	print(CurrentLevelData.current_level_data.active_hazards)
	#get_tree().change_scene_to_file("res://levels/house.tscn")
