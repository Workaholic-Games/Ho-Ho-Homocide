extends Area2D
class_name HazardItem

var hazard_name: String = ""

@onready var sprite: Sprite2D = $Sprite2D

func setup(name_of_hazard: String, texture_path: String) -> void:
	hazard_name = name_of_hazard
	sprite.texture = load(texture_path)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var level_node = get_tree().current_scene
		print(hazard_name)
		if level_node.has_method("on_player_hazard"):
			level_node.on_player_hazard(hazard_name)
