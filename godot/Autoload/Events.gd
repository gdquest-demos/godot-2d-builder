extends Node

@warning_ignore("unused_signal")
signal systems_ticked(delta)

@warning_ignore("unused_signal")
signal entity_placed(entity, cellv)
@warning_ignore("unused_signal")
signal entity_removed(entity, cellv)

@warning_ignore("unused_signal")
signal entered_pickup_area(entity, player)

@warning_ignore("unused_signal")
signal hovered_over_entity(entity)
@warning_ignore("unused_signal")
signal info_updated(entity)

@warning_ignore("unused_signal")
signal hovered_over_recipe(output, recipe)
