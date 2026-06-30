extends CharacterBody2D

func _physics_process(_delta):
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * SaveManager.player_data.speed
	move_and_slide()
