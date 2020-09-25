extends Entity

const REGIONS := [
	Rect2(10, 780, 100, 100),
	Rect2(120, 780, 100, 100),
	Rect2(230, 780, 100, 100)
]


func _ready() -> void:
	var index := int(rand_range(0, REGIONS.size() - 1))
	$Sprite.region_rect = REGIONS[index]
	get_child(index + 1).disabled = false
	scale.x = 1 if rand_range(0, 10) < 5.5 else -1
