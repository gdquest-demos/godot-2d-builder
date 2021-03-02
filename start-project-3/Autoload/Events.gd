extends Node

## Emitted when the player places an entity
signal entity_placed(entity, cellv)

## Emitted when the player removes an entity
signal entity_removed(entity, cellv)

## Emitted when the simulation triggers the systems for updates
signal systems_ticked(delta)

## Emitted when the player has arrived at an item that can be picked up
signal entered_pickup_area(entity, player)
