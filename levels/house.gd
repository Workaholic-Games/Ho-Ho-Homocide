extends Node2D

var level = LevelData.new()
var hazards = level.hazards

var duration : float = 300.0
@onready var awake_timer: ColorRect = $CanvasLayer/AwakeTime

func _ready() -> void:
	start_awake_timer()

func start_awake_timer() -> void:
	var shader_mat = awake_timer.material as ShaderMaterial
	shader_mat.set_shader_parameter("progress", 0.0)
	
	var tween = create_tween()
	tween.tween_property(shader_mat, "shader_parameter/progress", 1.0, duration)
	tween.tween_callback(end)

func end():
	print("[Member] has woken up!")

func set_hazards():
	pass
