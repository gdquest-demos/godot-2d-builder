extends Entity

const REGIONS := [
	Rect2(340, 780, 100, 100),
	Rect2(450, 780, 100, 100),
]


func _ready() -> void:
	var index := int(rand_range(0, REGIONS.size() - 1))
	$Sprite.region_rect = REGIONS[index]
	var collision: CollisionPolygon2D = get_child(index + 1)
	collision.disabled = false
	collision.show()
	scale.x = 1 if rand_range(0, 10) < 5.5 else -1
