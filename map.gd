extends Node2D

@export var ui : CanvasLayer
@onready var interaction_area : InteractionArea = $InteractionArea
@export var labels : Array[Node]

func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact() -> void:
	ui.show()

func _on_close_button_pressed() -> void:
	$AudioStreamPlayer2D.play(0.56)
	ui.hide()
