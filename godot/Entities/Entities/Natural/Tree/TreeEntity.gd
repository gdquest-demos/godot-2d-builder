extends Entity

const REGIONS := [
	Rect2(10, 560, 210, 210),
	Rect2(230, 560, 210, 210),
	Rect2(450, 560, 210, 210),
	Rect2(670, 560, 210, 210),
]


func _ready() -> void:
	$Foliage.region_rect = REGIONS[randi() % REGIONS.size()]
	$Foliage.flip_h = rand_range(0, 10) < 5.5


func get_entity_name() -> String:
	return "Lumber"
