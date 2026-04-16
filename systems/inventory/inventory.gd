extends Control

@onready var inventory_display: PanelContainer = $InventoryDisplay
@onready var inventory_grid: GridContainer = %InventoryGrid
@onready var button: Button = $Button

@export var items: Array[ItemData]
var slots: Array[ItemSlot]

var item_slot := preload("res://systems/inventory/item_slot.tscn")

signal hover_started(node: Node)
signal hover_ended(node: Node)

func _ready() -> void:
	add_to_group("interactables")
	toggle_inventory(false)
	
	for slot in range(9):
		add_slot()
		if items.size() > slot:
			slots[slot].item_data = items[slot]
	
	inventory_display.mouse_entered.connect(_on_mouse_entered.bind(inventory_display))
	inventory_display.mouse_exited.connect(_on_mouse_exited.bind(inventory_display))
	button.mouse_entered.connect(_on_mouse_entered.bind(button))
	button.mouse_exited.connect(_on_mouse_exited.bind(button))

func add_slot() -> void:
	var slot_instance = item_slot.instantiate()
	slots.append(slot_instance)
	inventory_grid.add_child(slot_instance)
	
	slot_instance.mouse_entered.connect(_on_mouse_entered.bind(slot_instance))
	slot_instance.mouse_exited.connect(_on_mouse_exited.bind(slot_instance))

func remove_slot(slot: ItemSlot) -> void:
	slots.erase(slot)
	slot.queue_free()

func toggle_inventory(visibility: bool) -> void:
	inventory_display.visible = visibility

func _on_button_toggled(toggled_on: bool) -> void:
	toggle_inventory(toggled_on)

func _on_mouse_entered(node: Node) -> void:
	hover_started.emit(node)

func _on_mouse_exited(node: Node) -> void:
	hover_ended.emit(node)
