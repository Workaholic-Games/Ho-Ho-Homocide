extends CharacterBody2D
class_name player
var username : String = ""



func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())

func _ready() -> void:
	if !MultiplayerManagement.playing_multiplayer:
		return
	
	if not is_multiplayer_authority(): 
		return
	
	$Camera2D.make_current()
	update_username()
	position = Vector2(336.0, 192.0)

func _physics_process(_delta):
	#if MultiplayerManagement.playing_multiplayer:
		#if not is_multiplayer_authority(): 
			#return
		#return
	#
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * SaveManager.player_data.speed
	move_and_slide()

func update_username():
	$Label.text = username
