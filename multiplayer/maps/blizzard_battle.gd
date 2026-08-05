extends Node2D

@onready var main = get_tree().get_root().get_node("/root/BlizzardBattle")
@onready var snowball = load("res://multiplayer/snowball.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$GPUParticles2D.emitting = true
	$"Player/Snowball Launcher".show()
