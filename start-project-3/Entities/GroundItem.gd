class_name GroundItem
extends Node2D

## Reference to the blueprint that was just dropped. Grabbed by the inventory
## GUI system when picked up.
var blueprint: BlueprintEntity

## Reference to the nodes that make up this scene so we can animate, tween, or
## toggle whether collisions work.
onready var collision_shape := $Area2D/CollisionShape2D
onready var animation := $AnimationPlayer
onready var sprite := $Sprite
onready var tween := $Tween


## Assigns a blueprint, sets graphics, and positions the entity
func setup(_blueprint: BlueprintEntity, location: Vector2) -> void:
	blueprint = _blueprint
	
	# We configure the sprite to be exactly how the blueprint entity's sprite is
	# so it looks the same, just scaled down.
	var blueprint_sprite := blueprint.get_node("Sprite")
	sprite.texture = blueprint_sprite.texture
	sprite.region_enabled = blueprint_sprite.region_enabled
	sprite.region_rect = blueprint_sprite.region_rect
	sprite.centered = blueprint_sprite.centered
	
	global_position = location
	
	# Trigger the "pop" animation, where the entity goes flying out of where the
	# entity was deconstructed.
	_pop()


## Animates the entity so it flies to the player's position before being erased.
func do_pickup(target: KinematicBody2D) -> void:
	# We start with a speed of 10% of the distance. The item starts slow.
	var travel_distance := 0.1
	
	# Prevent the collision of the shape from working, otherwise we might pick up
	# the same item twice in a row!
	collision_shape.set_deferred("disabled", true)

	# We'll manually break out of the loop when it's time, so keep looping.
	while true:
		# Calculate the distance to the player.
		var distance_to_target := global_position.distance_to(target.global_position)
		# Break out of the loop once we're inside of 5 pixels, which is sufficiently "on top."
		if distance_to_target < 5.0:
			break

		# Interpolate the current position of the ground item by a percentage
		# of the way to the target's position.
		global_position = global_position.move_toward(target.global_position, travel_distance)
		# In our case, starting at 10% and increasing by another 10 every frame,
		# Ramping slow to fast.
		travel_distance += 0.1
		
		# Yield out of the function call until next frame where we can keep animating.
		yield(get_tree(), "idle_frame")

	# Erase the ground item entity now that it's reached the player.
	queue_free()


## Animates the entity flying out of its starting position in an arc up and down,
## like popcorn.
func _pop() -> void:
	# PI in radians is half a circle, or 180 degrees. So this takes the up direction
	# and rotates it a random amount left and right.
	var direction := Vector2.UP.rotated(rand_range(-PI, PI))
	
	# In our isometric perspective, every vertical pixel is half a horizontal pixel.
	direction.y /= 2.0
	# Pick a random distance between 20 and 70 pixels.
	direction *= rand_range(20, 70)

	# Pre-calculate the final position
	var target_position := global_position + direction
	
	# Pre-calculate a point half way horizontally between start and end point,
	# but twice as high. `sign()` returns -1 if the value is negative and 1 if
	# positive, so we can use it to keep the vertical direction upwards.
	var height_position := global_position + direction * Vector2(0.5, 2 * -sign(direction.y))

	# Interpolate from the start to the middle point
	tween.interpolate_property(
		self,
		"global_position",
		global_position,
		height_position,
		0.15,
		Tween.TRANS_SINE,
		Tween.EASE_OUT
	)
	# then middle point to end point. We delay this twen by the duration of the
	# previous tween.
	tween.interpolate_property(
		self, "global_position", height_position, target_position, 0.25, 0, Tween.EASE_IN, 0.15
	)
	tween.start()
	
	# Wait until all tweens that we created have finished
	yield(tween, "tween_all_completed")
	animation.play("Float")
