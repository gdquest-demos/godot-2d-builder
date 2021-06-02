extends Entity

const REGIONS := [
	Rect2(12, 452, 38, 24),
	Rect2(52, 451, 25, 23),
	Rect2(79, 451, 30, 22),
	Rect2(12, 489, 24, 28),
	Rect2(38, 498, 42, 19),
	Rect2(83, 485, 26, 34),
	Rect2(12, 524, 27, 25),
	Rect2(45, 525, 31, 23),
	Rect2(87, 526, 21, 21)
]


func _ready() -> void:
	$Sprite.region_rect = REGIONS[randi() % REGIONS.size()]
