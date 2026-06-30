extends Node2D

func _process(_delta: float) -> void:
	$Label.text = "Holiday Cheer: " + str(Stats.holiday_cheer)

func _on_singleplayer_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/workshop.tscn")
	pass # Replace with function body.


func _on_button_3_pressed() -> void:
	Stats.holiday_cheer += 1
