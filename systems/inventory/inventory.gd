extends Control
## The main inventory logic.
##
## Keeps track of and displays all held items. Can be toggled open/closed.

## Parent of the main inventory UI.
@onready var inventory_display: PanelContainer = $InventoryDisplay

## [GridContainer] holding all [ItemSlot]s.
@onready var inventory_grid: GridContainer = %InventoryGrid

## [Button] for toggling the inventory's visibility.
@onready var button: Button = $Button

## All [Item]s currently in the inventory.
@export var items: Array[ItemData]

## All [ItemSlot]s currently in the inventory.
var slots: Array[ItemSlot]

## Base [ItemSlot] [PackedScene] to instantiate.
var item_slot := preload("res://systems/inventory/item_slot.tscn")

## Emitted when a connected [Node] is hovered over by the mouse.
signal hover_started(node: Node)

## Emitted when a connected [Node] stops being hovered over by the mouse.
signal hover_ended(node: Node)

func _ready() -> void:
	add_to_group("interactables")
	toggle_inventory()
	
	for item in items:
		add_slot(item)
	
	inventory_display.mouse_entered.connect(_on_mouse_entered.bind(inventory_display))
	inventory_display.mouse_exited.connect(_on_mouse_exited.bind(inventory_display))
	button.mouse_entered.connect(_on_mouse_entered.bind(button))
	button.mouse_exited.connect(_on_mouse_exited.bind(button))

## Adds a new [ItemSlot] to the inventory.
func add_slot(item: ItemData = null) -> void:
	var slot_instance = item_slot.instantiate()
	slots.append(slot_instance)
	inventory_grid.add_child(slot_instance)
	
	slot_instance.mouse_entered.connect(_on_mouse_entered.bind(slot_instance))
	slot_instance.mouse_exited.connect(_on_mouse_exited.bind(slot_instance))
	
	if item:
		slot_instance.item_data = item

## Removes an [ItemSlot] from the inventory.
func remove_slot(slot: ItemSlot) -> void:
	slots.erase(slot)
	slot.queue_free()

## Hides/displays the inventory display panel, by default based on [member button]'s state.
func toggle_inventory(visibility := button.button_pressed) -> void:
	inventory_display.visible = visibility
	if button.button_pressed != visibility:
		button.button_pressed = visibility

## Triggered when the [member button] is pressed.
func _on_button_toggled(toggled_on: bool) -> void:
	toggle_inventory(toggled_on)

## Triggered when one of the connected [Node]s is hovered over.
func _on_mouse_entered(node: Node) -> void:
	hover_started.emit(node)

## Triggered when one of the connected [Node]s is no longer being hovered over.
func _on_mouse_exited(node: Node) -> void:
	hover_ended.emit(node)
