extends Node

## Signal emitted when the player places an entity
signal entity_placed(entity, cellv)

## Signal emitted when the player removes an entity
signal entity_removed(entity, cellv)

## Signal emitted when the simulation triggers the systems for updates
signal systems_ticked(delta)
