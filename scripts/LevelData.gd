extends Resource
class_name  LevelData

var difficulty : int = 1

var hazards : Dictionary = {
	"Floorboard": {
		"noise_level": 3,
	},
	"Can": {
		"noise_level": 6
	},
	"Toy": {
		"noise_level": 10
	}
}

var active_hazards : Dictionary = {}

var naughty_clues : Array[String] = [
	"Dirt",
	"Clothes",
]
var nice_clue : Array[String] = [
	"Milk and Cookies",
	"Clean",
]

func scale_hazards() -> void:
	active_hazards.clear()
	var multiplier = 1.0 + ((difficulty-1) * 0.2)
	for hazard_name in hazards:
		var noise = hazards[hazard_name]["noise_level"]
		var scaled_noise = roundi(noise * multiplier)
		active_hazards[hazard_name] = {
			"noise_level": scaled_noise
		}
