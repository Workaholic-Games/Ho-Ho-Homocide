extends StaticBody2D
class_name wall

var health : int = 10

func update_health():
	if health <= 0:
		queue_free()
