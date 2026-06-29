extends Node2D

@export var ui : CanvasLayer

@onready var interaction_area : InteractionArea = $InteractionArea

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact():
	$Computer.play()
	await $Computer.animation_finished
	ui.show()
	print("BEEP BOOP")


func _on_close_button_pressed() -> void:
	$AudioStreamPlayer2D.play(0.56)
	ui.hide()
	$Computer.play_backwards("open")
