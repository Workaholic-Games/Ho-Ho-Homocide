extends Camera2D

@export var tilemap : TileMapLayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var mapsize = tilemap.get_used_rect()
	var tilesize = tilemap.rendering_quadrant_size
	var worldsizepixels = mapsize.size * tilesize
	limit_right = worldsizepixels.x
	limit_bottom = worldsizepixels.y
	print(limit_bottom)
