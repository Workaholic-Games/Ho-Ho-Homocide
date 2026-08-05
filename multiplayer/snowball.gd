extends Area2D

const impact = preload("res://multiplayer/particle.tscn")

const SPEED : int = 300
const damage : int = 1
var rotate_speed : int = randi_range(2, 10)

func _process(delta: float) -> void:
	position += transform.x * SPEED * delta
	$Sprite2D.rotation += rotate_speed * delta
	


func _on_timer_timeout() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	var instance = impact.instantiate()
	get_tree().root.add_child(instance)
	instance.global_position = self.global_position
	instance.get_child(0).emitting = true
	
	queue_free()
	if body is wall:
		body.health -= damage
		body.update_health()
