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


func _on_multiplayer_pressed() -> void:
	$Camera2D/Buttons.hide()
	$Camera2D/Host.show()
	$Camera2D/Join.show()


func _on_host_pressed() -> void:
	pass # Replace with function body.


func _on_join_pressed() -> void:
	pass # Replace with function body.
