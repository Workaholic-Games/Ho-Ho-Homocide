extends Camera2D

@onready var tilemap = self.get_tree().get_first_node_in_group("CameraBounds")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var mapsize = tilemap.get_used_rect()
	var tilesize = tilemap.rendering_quadrant_size
	var worldsizepixels = mapsize.size * tilesize
	limit_right = worldsizepixels.x
	limit_bottom = worldsizepixels.y
	print(limit_bottom)
