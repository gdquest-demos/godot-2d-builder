extends Entity

## The total amount of power the battery is able to hold at max capacity
export var max_storage := 1000.0

## The actual amount of power the battery is currently holding
var stored_power := 0.0 setget _set_stored_power

## The two components for receiver and source so we can control efficiency
onready var receiver := $PowerReceiver
onready var source := $PowerSource
onready var indicator := $Indicator


func _ready() -> void:
	# Call the setter with the default value. This sets the receiver and source
	# components efficiencies at the start of the entity's lifespan.
	_set_stored_power(stored_power)
	
	# If the source is not omni-directional:
	if source.output_direction != 15:
		# set the receiver direction to the _opposite_ of the source.
		# The ^ is the XOR (exclusive or) operator.
		# If | returns 1 if either bit is 1, and & returns 1 if both bits are 1,
		# ^ returns 1 if the bits _do not_ match.

		# This effectively inverts the number for enum flags.
		receiver.input_direction = 15 ^ source.output_direction


## The setup function fetches the direction from the blueprint and applies it
## to the source, and inverts it for the receiver with XOR.
func _setup(blueprint: BlueprintEntity) -> void:
	source.output_direction = blueprint._power_indicator.output_directions
	receiver.input_direction = 15 ^ source.output_direction


## Set the efficiency in source and receiver based on the amount of stored power
func _set_stored_power(value: float) -> void:
	# Set the stored power. Do not allow it to become negative.
	stored_power = max(value, 0)

	# Wait until the entity has been in the scene tree
	if not is_inside_tree():
		yield(self, "ready")

	# Set the receiver's efficiency.
	receiver.efficiency = (
		0.0
		# If the battery is full, set it to 0. We don't want it to draw more power.
		if stored_power >= max_storage
		# If the battery is less than full, set it to the minimum between 1 and
		# the percentage of how empty the battery is.
		# This makes the battery fill up slower as it approaches being full.
		else min((max_storage - stored_power) / receiver.power_required, 1.0)
	)

	# Set the source efficiency to 0 there is no power, otherwise set it to a percentage of how full
	# the battery is. A battery that has more power than it must provide returns 1 whereas a battery
	# that has less returns some percentage of that.
	source.efficiency = (0.0 if stored_power <= 0 else min(stored_power / source.power_amount, 1.0))
	
	indicator.material.set_shader_param("amount", stored_power / max_storage)


## Sets the stored power using the setter based on the received amount of power per second
func _on_PowerReceiver_received_power(amount: float, delta: float) -> void:
	self.stored_power = stored_power + amount * delta


## Sets the stored power using the setter based on the amount of power provided per second
func _on_PowerSource_power_updated(power_draw: float, delta: float) -> void:
	self.stored_power = stored_power - min(power_draw, source.get_effective_power()) * delta
