extends Node2D


func _process(_delta: float) -> void:
	$Label.text = "Holiday Cheer: " + str(SaveManager.player_data.holiday_cheer)
	if Input.is_action_just_pressed("save"):
		SaveManager.save_data()
	if Input.is_action_just_pressed("load"):
		SaveManager.load_data()


func _on_singleplayer_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/workshop.tscn")
	pass # Replace with function body.


func _on_button_3_pressed() -> void:
	SaveManager.player_data.change_holiday_cheer(10)
