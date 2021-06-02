extends Entity

const REGIONS := [Rect2(10, 780, 100, 100), Rect2(120, 780, 100, 100), Rect2(230, 780, 100, 100)]


func _ready() -> void:
	var index := randi() % REGIONS.size()
	$Sprite.region_rect = REGIONS[index]
	var collision: CollisionPolygon2D = get_child(index + 1)
	collision.disabled = false
	collision.show()
	scale.x = 1 if rand_range(0, 10) < 5.5 else -1


func get_entity_name() -> String:
	return "Stone"
