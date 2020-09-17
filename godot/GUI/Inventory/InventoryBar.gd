# Class that represents a bar of inventory slots. Transmits blueprint events up
# to the preview controller.
class_name InventoryBar
extends HBoxContainer


signal inventory_changed(panel, held_item)


export var InventoryPanelScene: PackedScene
export var slot_count := 10
export var item_filters := ""


var panels := []


func _ready() -> void:
	_make_panels()


func setup(gui: Control) -> void:
	for panel in panels:
		panel.setup(gui, item_filters)
		if not panel.is_connected("held_item_changed", self, "_on_Panel_held_item_changed"):
			panel.connect("held_item_changed", self, "_on_Panel_held_item_changed")


func _make_panels() -> void:
	for _i in slot_count:
		var panel := InventoryPanelScene.instance()
		add_child(panel)
		panels.append(panel)


func _on_Panel_held_item_changed(panel: Control, held_item: BlueprintEntity) -> void:
	emit_signal("inventory_changed", panel, held_item)
