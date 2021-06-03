extends Entity

## Both regions that represent an ore boulder in the sprite sheet
const REGIONS := [
	Rect2(340, 780, 100, 100),
	Rect2(450, 780, 100, 100),
]


func _ready() -> void:
	# Get a random index and set the sprite and enable the correct collision
	var index := randi() % REGIONS.size()
	$Sprite.region_rect = REGIONS[index]
	
	var collision: CollisionPolygon2D = get_child(index + 1)
	collision.disabled = false
	collision.show()
	
	# Randomly flip the entity for more variety
	scale.x = 1 if rand_range(0, 10) < 5.5 else -1


func get_entity_name() -> String:
	return "Ore"
