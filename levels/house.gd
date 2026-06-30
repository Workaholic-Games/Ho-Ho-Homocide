extends Node2D

func _process(_delta: float) -> void:
	$CanvasLayer/ProgressBar.value = $"Awake Timer".wait_time - $"Awake Timer".time_left
