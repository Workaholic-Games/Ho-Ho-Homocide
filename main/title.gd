extends Node2D
@export var random_strength: float = 20.0
@export var shake_fade: float = 5.0
var text = "*Requires:"
var shake_strength: float = 0
var username_requirement: bool = false
var code_requirement: bool = false
@onready var code: LineEdit = $Camera2D/MultiplayerButtons/code

func apply_strength():
	shake_strength = random_strength


func _process(delta: float) -> void:
	$Label.text = "Holiday Cheer: " + str(SaveManager.player_data.holiday_cheer)
	if Input.is_action_just_pressed("save"):
		SaveManager.save_data()
	if Input.is_action_just_pressed("load"):
		SaveManager.load_data()
	if shake_strength > 0.0:
		shake_strength = lerpf(shake_strength, 0, shake_fade * delta)
		$Camera2D.offset.x = randf_range(-shake_strength, shake_strength)
		
func _on_singleplayer_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/workshop.tscn")


func _on_button_3_pressed() -> void:
	SaveManager.player_data.change_holiday_cheer(10)


func _on_multiplayer_pressed() -> void:
	$Camera2D/Buttons.hide()
	$Camera2D/MultiplayerButtons.show()




func _on_host_pressed() -> void:
	if !$Camera2D/MultiplayerButtons/username.text:
		$Camera2D/Requires.show()
		if !username_requirement:
			$Camera2D/Requires.text += "\nUsername"
			username_requirement = !username_requirement
		apply_strength()
		return
	MultiplayerManagement.host_pressed = true
	get_tree().change_scene_to_file("res://multiplayer/multiplayer_lobby.tscn")


func _on_join_pressed() -> void:
	if !$Camera2D/MultiplayerButtons/code.text:
		$Camera2D/Requires.show()
		if !code_requirement:
			$Camera2D/Requires.text += "\nInput Code"
			code_requirement = !code_requirement
		apply_strength()
		return
	elif !$Camera2D/MultiplayerButtons/username.text:
		$Camera2D/Requires.show()
		if !username_requirement:
			$Camera2D/Requires.text += "\nUsername"
			username_requirement = !username_requirement
		apply_strength()
		return
	
	MultiplayerManagement.join_pressed = true
	MultiplayerManagement.join_code = code.text.to_int()
	get_tree().change_scene_to_file("res://multiplayer/multiplayer_lobby.tscn")
