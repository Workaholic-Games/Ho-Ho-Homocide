extends Node2D

const snowball = preload("res://multiplayer/snowball.tscn")
const max_ammo : int = 25

var ammo : int = max_ammo

var is_cooldown : bool = false
@onready var barrel: Marker2D = $Marker2D

func _ready() -> void:
	update_ammo()

func _process(_delta: float) -> void:
	look_at(get_global_mouse_position())
	
	rotation_degrees = wrap(rotation_degrees, 0, 360)
	if rotation_degrees > 90 and rotation_degrees < 270:
		scale.y = -1
	else:
		scale.y = 1
	
	if Input.is_action_just_pressed("shoot") and ammo > 0 and MultiplayerManagement.mode == 1:
		if is_cooldown:
			return
		if MultiplayerManagement.mode != 1:
			return
		$cooldown.start()
		var instance = snowball.instantiate()
		get_tree().root.add_child(instance)
		instance.global_position = barrel.global_position
		instance.rotation = global_rotation
		is_cooldown = true
		ammo -= 1
		update_ammo()

func update_ammo():
	get_parent().get_child(9).get_child(0).text = "Ammo: " + str(ammo) + "/" + str(max_ammo)

func _on_cooldown_timeout() -> void:
	is_cooldown = false
