extends Resource
class_name PlayerData

@export var speed : float = 150

@export var holiday_cheer : int = 0

@export var SavePos : Vector2

func change_holiday_cheer(value : int) -> void:
	holiday_cheer += value
	
func update_pos(value : Vector2) -> void:
	SavePos = value
