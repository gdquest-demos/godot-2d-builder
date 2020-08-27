class_name PowerComponent
extends Node


enum PowerRole { POWER_PROVIDER = 1, POWER_CONSUMER = 2, POWER_MOVER = 4, POWER_STORER = 8 }

signal state_changed


export(PowerRole, FLAGS) var power_role := 4
export var power_amount := 0

var current_power_amount := power_amount
var is_powered := false
