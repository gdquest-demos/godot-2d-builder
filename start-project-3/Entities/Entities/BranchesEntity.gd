extends Entity

const REGIONS := [
	Rect2(135, 450, 24, 42),
	Rect2(177, 450, 41, 42),
	Rect2(125, 505, 39, 45),
	Rect2(180, 498, 38, 52)
]


func _ready() -> void:
	$Sprite.region_rect = REGIONS[randi() % REGIONS.size()]
