## Holds references to entities in the world, and a series of paths that go from power sources
## to power receivers. Every system tick, it sends power from the sources to the
## receivers in order.
class_name PowerSystem
extends Reference

## Holds a set of power source components keyed by their map position
var power_sources := {}
## Holds a set of power receiver components keyed by their map position
var power_receivers := {}
## Holds a set of power mover entities, keyed by their map position
var power_movers := {}

## An array of 'power paths'. Those arrays are map positions with [0] being
## the location of a power source and the rest being receivers.
var paths := []

## A running tally of the amount of power available to a given path during updates.
var power_left := 0.0

## The cells that have already been verified while building a power path. This
## allows us to skip revisiting cells that are already in the list so we only
## travel outwards.
var cells_travelled := []

## This set is used to keep track of how much power each receiver has already gotten.
## If you have 2 power sources with 10 units of power each feeding a machine that takes
## 20, then each will provide 10 over both paths. This list is where we keep track of that.
var receivers_already_provided := {}


func _init() -> void:
	Events.connect("entity_placed", self, "_on_entity_placed")
	Events.connect("entity_removed", self, "_on_entity_removed")
	Events.connect("systems_ticked", self, "_on_systems_ticked")


## Replace all paths with new ones based on the current state of the components
func _retrace_paths() -> void:
	# Clear old paths
	paths.clear()

	# For each power source
	for source in power_sources.keys():
		# Start a brand new path trace so all cells are possible contenders
		cells_travelled.clear()
		
		# Trace the path the current cell location, with an array with it as [0]
		var path := _trace_path_from(source, [source])

		# Add the result to the paths array
		paths.push_back(path)


## Recursively trace a path from the source cell outwards, skipping already
## visited cells, only going through cells that has been recognized by the
## power system.
func _trace_path_from(cellv: Vector2, path: Array) -> Array:
	# As soon as we reach any given cell, we keep track that we've already visited it.
	# Recursive functions are sensitive to overflowing, so this ensures we won't
	# travel back and forth between two cells forever until the game crashes.
	cells_travelled.push_back(cellv)

	# The default direction for most components, like the generator, is omni-directional,
	# that's UP + LEFT + RIGHT + DOWN in our Types.
	var direction := 15

	# If the current cell is a power source component, use _its_ direction instead.
	if power_sources.has(cellv):
		direction = power_sources[cellv].output_direction

	# Get the power receivers that are neighbors to this cell, if there are any,
	# based on the direction.
	var receivers := _find_neighbors_in(cellv, power_receivers, direction)
	
	# For each power receiver
	for receiver in receivers:
		# If we have NOT visited it already
		if not receiver in cells_travelled:
			# Create an integer that indicates the direction power is currently
			# traveling in to compare it to the receiver's direction.
			# I.E. if the power is traveling from left to right but the receiver
			# does not accept power coming from _its_ left, it should not be in the list.
			direction = _combine_directions(receiver, cellv)

			# Get the power receiver
			var power_receiver: PowerReceiver = power_receivers[receiver]
			# If the current direction does not match any of the receiver's possible
			# directions (using the binary and operator, &, to check if the number fits
			# inside the other), skip this receiver and move on to the next one.
			if (
				(
					direction & Types.Direction.RIGHT != 0
					and power_receiver.input_direction & Types.Direction.LEFT == 0
				)
				or (
					direction & Types.Direction.DOWN != 0
					and power_receiver.input_direction & Types.Direction.UP == 0
				)
				or (
					direction & Types.Direction.LEFT != 0
					and power_receiver.input_direction & Types.Direction.RIGHT == 0
				)
				or (
					direction & Types.Direction.UP != 0
					and power_receiver.input_direction & Types.Direction.DOWN == 0
				)
			):
				continue
				
			# Otherwise, add it to the path.
			path.push_back(receiver)

	# We've done the receivers, now we check for any possible wires so we can keep
	# traveling.
	var movers := _find_neighbors_in(cellv, power_movers)

	# Call this same function again from the new cell position for any wire that
	# is found and travel from there, and return the result, so long as we've
	# not visited it already.
	for mover in movers:
		if not mover in cells_travelled:
			path = _trace_path_from(mover, path)

	# Return the final array
	return path


## Compare a source to a target map position and return a direction integer
## that indicates the direction power is traveling in.
func _combine_directions(receiver: Vector2, cellv: Vector2) -> int:
	if receiver.x < cellv.x:
		return Types.Direction.LEFT
	elif receiver.x > cellv.x:
		return Types.Direction.RIGHT
	elif receiver.y < cellv.y:
		return Types.Direction.UP
	elif receiver.y > cellv.y:
		return Types.Direction.DOWN

	return 0


## For each neighbor in the given direction, check if it exists in the collection we specify,
## and return an array of map positions with those that do.
func _find_neighbors_in(cellv: Vector2, collection: Dictionary, output_directions: int = 15) -> Array:
	var neighbors := []
	# For each of UP, DOWN, LEFT and RIGHT
	for neighbor in Types.NEIGHBORS.keys():
		
		# One number & another results compared each binary bit of the two numbers.
		# This results in a number whose bits that match are set to 1 and those that don't to 0
		# For example, 1 is 0001, 2 is 0010, and 3 is 0011, and 4 is 0100.
		# We can say that 3 contains 1 and 2 because 3 contains both right most bits,
		# but 4 & 3 gives us 0 because none of the bits match.
		# This condition means if the current neighbor flag has bits that match the
		# specified direction:
		if neighbor & output_directions != 0:
			
			# Calculate its map coordinate
			var key: Vector2 = cellv + Types.NEIGHBORS[neighbor]
			
			# If it's in the specified collection, add it to the neighbors array
			if collection.has(key):
				neighbors.push_back(key)

	# Return the array of neighbors that match the collection
	return neighbors


## For each tick of the system, calculate the power for each path and notify
## the components.
func _on_systems_ticked(delta: float) -> void:
	# We're in a new tick, so clear all power received and start over.
	receivers_already_provided.clear()

	# For each power path
	for path in paths:
		# Get the path's power source, which is the first element
		var power_source: PowerSource = power_sources[path[0]]

		# Get the effective power it has to give. It cannot provide more than.
		var available_power := power_source.get_effective_power()
		
		# A running tally of the 
		var power_draw := 0.0

		# For each power receiver in the path (elements after 0)
		for cell in path.slice(1, path.size()-1):
			# If, for some reason, the element is not being kept track of, skip it.
			if not power_receivers.has(cell):
				continue

			# Get the actual power receiver component and calculate how much power
			# it desires.
			var power_receiver: PowerReceiver = power_receivers[cell]
			var power_required := power_receiver.get_effective_power()

			# Keep track of the total amount of power each receiver has already
			# received, in case of multiple power sources. Subtract the power
			# the receiver still needs so we don't draw more than necessary.
			if receivers_already_provided.has(cell):
				var receiver_total: float = receivers_already_provided[cell]
				if receiver_total >= power_required:
					continue
				else:
					power_required -= receiver_total

			# Notify the receiver of the power available to it from this source
			power_receiver.emit_signal(
				"received_power", min(available_power, power_required), delta
			)

			# Add to the tally of the power required from this power source
			power_draw += power_required

			# Add to the running tally for this particular cell for
			# any future power source. Add it, if it does not exist.
			if not receivers_already_provided.has(cell):
				receivers_already_provided[cell] = min(available_power, power_required)
			else:
				receivers_already_provided[cell] += min(available_power, power_required)

			# Reduce the amount of power still available to other receivers by the
			# amount that _this_ receiver took.
			available_power -= power_required

		# Notify the power source of the amount of power that has been asked of it.
		power_source.emit_signal("power_updated", power_draw, delta)


## Searches for a PowerSource component in the entity's children. Returns null
## if it is missing.
func _get_power_source_from(entity: Node) -> PowerSource:
	# For each child in the entity
	for child in entity.get_children():
		# Return the child if it is the component we need
		if child is PowerSource:
			return child

	return null


## Searches for a PowerReceiver component in the entity's children. Returns null
## if it is missing.
func _get_power_receiver_from(entity: Node) -> PowerReceiver:
	for child in entity.get_children():
		if child is PowerReceiver:
			return child

	return null


## Detects when a new entity has been placed and puts its location in the respective
## dictionary if it's part of the powers groups. Triggers an update of power paths.
func _on_entity_placed(entity, cellv: Vector2) -> void:
	# A running tally of whether or not we should update paths. If the new entity
	# is in none of the power groups, we don't need to update anything, so false
	# is the default.
	var retrace := false

	# Check if the entity is in the power sources or receivers groups. If it is,
	# get its component using a helper function, and trigger a power path update.
	if entity.is_in_group(Types.POWER_SOURCES):
		power_sources[cellv] = _get_power_source_from(entity)
		retrace = true

	if entity.is_in_group(Types.POWER_RECEIVERS):
		power_receivers[cellv] = _get_power_receiver_from(entity)
		retrace = true

	# If it is a power mover, store the entity and trigger a power path update.
	if entity.is_in_group(Types.POWER_MOVERS):
		power_movers[cellv] = entity
		retrace = true

	# Update the power paths
	if retrace:
		_retrace_paths()


## Detects when an entity has been removed. If any of our dictionaries held this
## location, erase it and trigger a path update.
func _on_entity_removed(_entity, cellv: Vector2) -> void:
	# Dictionary::erase returns true if it found the key and erased it successfully.
	var retrace := power_sources.erase(cellv)
	
	# Note the use of `or`. If any of the previous flags came back true, we don't
	# want to overwrite the previous true.
	retrace = power_receivers.erase(cellv) or retrace
	retrace = power_movers.erase(cellv) or retrace

	# Update the power paths
	if retrace:
		_retrace_paths()
