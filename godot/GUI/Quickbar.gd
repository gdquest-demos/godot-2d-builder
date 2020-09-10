extends HBoxContainer


signal quickbar_changed


var held_item: BlueprintEntity setget _set_held_item, _get_held_item
var drag_preview: Control
var inventory_quickbar: Control

var panels := []


func _ready() -> void:
	for container in get_children():
		panels.push_back(container.get_child(1))


func setup(_drag_preview: Control, _inventory_quickbar: Control = null) -> void:
	drag_preview = _drag_preview
	inventory_quickbar = _inventory_quickbar


func _mirror_bars(bar_a: Control, bar_b: Control) -> void:
	for i in bar_a.panels.size():
		var inventory_panel: Panel = bar_a.panels[i]
		var mirror_panel: Panel = bar_b.panels[i]
		
		mirror_panel.begin_silence()
		inventory_panel.begin_silence()
		
		if mirror_panel.held_item:
			mirror_panel.held_item.queue_free()
			mirror_panel.held_item = null
		if inventory_panel.held_item:
			mirror_panel.held_item = inventory_panel.held_item.duplicate()
			mirror_panel.held_item.stack_count = inventory_panel.held_item.stack_count

		mirror_panel.end_silence()
		inventory_panel.end_silence()

		mirror_panel._update_label()
		inventory_panel._update_label()


func destroy_held_item() -> void:
	drag_preview.destroy_blueprint()


func _on_Panel_held_item_changed() -> void:
	emit_signal("quickbar_changed")


func _on_InventoryWindow_quickbar_changed() -> void:
	_mirror_bars(inventory_quickbar, self)


func _set_held_item(value: BlueprintEntity) -> void:
	drag_preview.blueprint = value


func _get_held_item() -> BlueprintEntity:
	if drag_preview:
		return drag_preview.blueprint
	else:
		return null


func _on_Quickbar_quickbar_changed() -> void:
	_mirror_bars(self, inventory_quickbar)
