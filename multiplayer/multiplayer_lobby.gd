extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await  get_tree().create_timer(.5).timeout
	$CanvasLayer/HBoxContainer/Label.text += str(MultiplayerManagement.join_code)


func _on_copy_pressed() -> void:
	var text_to_copy = str(MultiplayerManagement.join_code)
	DisplayServer.clipboard_set(text_to_copy)
