extends Node2D

var level = CurrentLevelData.current_level_data

var hazard_scene: PackedScene = preload("res://hazard.tscn")

var duration : float = 300.0
var active_tween : Tween
@onready var awake_timer: ColorRect = $CanvasLayer/AwakeTime
@onready var tilemap: TileMapLayer = $Floor

func _ready() -> void:
	start_awake_timer(0.0)
	set_hazards(randi_range(5, 10))

func start_awake_timer(start_progress: float) -> void:
	if active_tween && active_tween.is_valid():
		active_tween.kill()
	var shader_mat = awake_timer.material as ShaderMaterial
	shader_mat.set_shader_parameter("progress", start_progress)
	
	var remaining_time = duration * (1.0 - start_progress)
	if remaining_time <= 0:
		end()
		return
	
	active_tween = create_tween()
	active_tween.tween_property(shader_mat, "shader_parameter/progress", 1.0, remaining_time)
	active_tween.tween_callback(end)

func subtract_time(seconds_to_lose: float) -> void:
	var shader_mat = awake_timer.material as ShaderMaterial
	var current_progress = shader_mat.get_shader_parameter("progress") as float
	
	var progress_penalty = seconds_to_lose / duration
	var new_progress = current_progress + progress_penalty
	
	new_progress = clamp(new_progress, 0.0, 1.0)
	
	start_awake_timer(new_progress)

func end():
	print("[Member] has woken up!")

func set_hazards(amount: int):
	var available_hazards = level.active_hazards.keys()
	if available_hazards.is_empty() || !tilemap: return
	
	var used_tiles = tilemap.get_used_cells()
	if used_tiles.is_empty(): return
	for i in range(amount):
		var random_type = available_hazards.pick_random()
		
		var sprite_path = level.active_hazards[random_type]["sprite_path"]
		
		var new_hazard = hazard_scene.instantiate() as HazardItem
		add_child(new_hazard)
		new_hazard.setup(random_type, sprite_path)
		
		var random_tile_coords = used_tiles.pick_random()
		
		var spawn_position = tilemap.map_to_local(random_tile_coords)
		
		if random_type == "Floorboard" && tilemap:
			new_hazard.position = spawn_position
		else:
			var offset = Vector2(randi_range(-16, 16), randi_range(-16, 16))
			new_hazard.position = spawn_position + offset

func on_player_hazard(hazard_name: String):
	var time_to_subtract = level.get_time_lost(hazard_name)
	print(time_to_subtract)
	subtract_time(time_to_subtract)
