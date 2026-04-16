extends Control

@onready var inventory_display: PanelContainer = $InventoryDisplay

signal hover_started(node: Node)
signal hover_ended(node: Node)

func _ready() -> void:
	toggle_inventory(false)

func toggle_inventory(visibility: bool) -> void:
	inventory_display.visible = visibility

func _on_button_toggled(toggled_on: bool) -> void:
	toggle_inventory(toggled_on)

func _on_button_mouse_entered() -> void:
	hover_started.emit(self)

func _on_button_mouse_exited() -> void:
	hover_ended.emit(self)
