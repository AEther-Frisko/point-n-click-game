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
@export var item_list: Array[ItemData]

## All [ItemSlot]s currently in the inventory.
var slot_list: Array[ItemSlot]

## Minimum no. of [ItemSlots] to be displayed.
var base_slot_num := 9

## Base [ItemSlot] [PackedScene] to instantiate.
var item_slot := preload("res://systems/inventory/item_slot.tscn")

## Emitted when a connected [Node] is hovered over by the mouse.
signal hover_started(node: Node)

## Emitted when a connected [Node] stops being hovered over by the mouse.
signal hover_ended(node: Node)

func _ready() -> void:
	add_to_group("interactables")
	toggle_inventory()
	reset_inventory()
	
	inventory_display.mouse_entered.connect(_on_mouse_entered.bind(inventory_display))
	inventory_display.mouse_exited.connect(_on_mouse_exited.bind(inventory_display))
	button.mouse_entered.connect(_on_mouse_entered.bind(button))
	button.mouse_exited.connect(_on_mouse_exited.bind(button))

## Adds a new [ItemSlot] to the inventory.
func add_slot(item_data: ItemData = null) -> void:
	var slot_instance = item_slot.instantiate()
	slot_list.append(slot_instance)
	inventory_grid.add_child(slot_instance)
	
	slot_instance.mouse_entered.connect(_on_mouse_entered.bind(slot_instance))
	slot_instance.mouse_exited.connect(_on_mouse_exited.bind(slot_instance))
	
	if item_data:
		slot_instance.item_data = item_data

## Removes an [ItemSlot] from the inventory.
func remove_slot(slot: ItemSlot) -> void:
	slot_list.erase(slot)
	slot.queue_free()

## Removes all [ItemSlot]s from the inventory.
func clear_slots() -> void:
	for slot_index in slot_list.size():
		slot_list[slot_index].queue_free()
	slot_list.clear()

## Adds a new [ItemData] to the [member item_list], and updates the inventory to match.
func add_item_data(item_data: ItemData) -> void:
	item_list.append(item_data)
	update_inventory()

## Removes an [ItemData] from the [member item_list] and updates the inventory to match.
func remove_item_data(item_data: ItemData) -> void:
	item_list.erase(item_data)
	update_inventory()

## Updates indentory without removing existing [ItemData].
func update_inventory() -> void:
	for item_index in max(slot_list.size(), item_list.size()):
		if item_list.size() > item_index:
			update_slot_data(slot_list[item_index], item_list[item_index])
		else:
			update_slot_data(slot_list[item_index])

## Re-draws [ItemSlot]s to ensure all [ItemData] is correct.
func reset_inventory() -> void:
	clear_slots()
	for item_index in max(base_slot_num, item_list.size()):
		if item_list.size() > item_index:
			add_slot(item_list[item_index])
		else:
			add_slot()

func update_slot_data(slot: ItemSlot, item_data: ItemData = null) -> void:
	slot.item_data = item_data

## Hide an [Item] without actually removing it from the [ItemSlot].
func hide_item(item: Item) -> void:
	for slot in slot_list:
		if slot.current_item == item:
			slot.current_item.visible = false
			return

## Show a previously-hidden [Item].
func show_item(item: Item) -> void:
	for slot in slot_list:
		if slot.current_item == item:
			slot.current_item.visible = true
			return

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
