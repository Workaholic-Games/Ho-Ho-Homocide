extends CharacterBody2D
class_name player

const snow_wall = preload("res://multiplayer/snow_wall.tscn")

@export var username : String = ""
var team: String = ""
var mode : int = 1

var wall_count : int = 3
var can_place : bool = true
var in_range : bool

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	username = MultiplayerManagement.username

func _ready() -> void:
	
	$Camera2D.make_current()
	update_username()
	position = Vector2(336.0, 192.0)

func _physics_process(_delta):
	if MultiplayerManagement.is_playing:
		if !is_multiplayer_authority():
			return
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * SaveManager.player_data.speed
	move_and_slide()
	$"Placement Preview".global_position = get_global_mouse_position()
	if $"Placement Preview/ShapeCast2D".is_colliding() or !in_range:
		$"Placement Preview".modulate = Color(0.767, 0.12, 0.161, 0.341)
		can_place = false
	else:
		$"Placement Preview".modulate = Color("00b1c757")
		can_place = true

func update_username():
	#print(username)
	$Label.text = username
	print("username: ", $Label.text)

func update_team_visuals():
	if team == "naughty":
		print("naughty")
		$Label.add_theme_color_override("font_color", Color(0.812, 0.0, 0.0, 1.0))

func _input(_event: InputEvent) -> void:
	if mode == 0:
		return

	if Input.is_action_just_pressed("shoot mode"):
		mode = 1
		$"Placement Preview".hide()
		$"Snowball Launcher".show()

	elif Input.is_action_just_pressed("build mode") and can_place:
		mode = 2
		$"Placement Preview".show()
		$"Snowball Launcher".hide()

	elif Input.is_action_just_pressed("dig mode"):
		mode = 3
		$"Snowball Launcher".hide()
		$"Placement Preview".hide()

	if Input.is_action_just_pressed("shoot") and wall_count > 0 and can_place and in_range and mode == 2:
		var instance = snow_wall.instantiate()

		get_tree().root.add_child(instance)
		instance.global_position = $"Placement Preview".global_position
		instance.rotation = $"Placement Preview".global_rotation

		wall_count -= 1
		if wall_count == 0:
			can_place = false
			mode = 1
			$"Placement Preview".hide()

		print(wall_count)

	elif Input.is_action_just_pressed("shoot") and mode == 3:
		pass

	if Input.is_action_just_pressed("rotate_left"):
		$"Placement Preview".rotation_degrees -= 30

	elif Input.is_action_just_pressed("rotate_right"):
		$"Placement Preview".rotation_degrees += 30

func _on_build_range_mouse_exited() -> void:
	in_range = false

func _on_build_range_mouse_entered() -> void:
	in_range = true

func _on_snowball_pressed() -> void:
	$"Snowball Launcher".update_ammo()
	if $"Snowball Launcher".ammo < $"Snowball Launcher".max_ammo:
		$"Snowball Launcher".ammo += 3
