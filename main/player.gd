extends CharacterBody2D
class_name player
var players = MultiplayerManagement.players
@export var username : String = ""
var team: String = ""


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
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * SaveManager.player_data.speed
	move_and_slide()

func update_username():
	#print(username)
	$Label.text = username
	print("username: ", $Label.text)

func update_team_visuals():
	if team == "naughty":
		print("naughty")
		$Label.add_theme_color_override("font_color", Color(0.812, 0.0, 0.0, 1.0))
		if players[1]:
			print("Grinch: ", players[1])
	else:
		print("Nice")
		if team[1]:
			print("Santa")
