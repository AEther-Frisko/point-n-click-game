class_name ItemSlot extends PanelContainer
## A slot for holding an [Item] in the inventory.
##
## Can either be empty or hold an item, which is determined by attached [ItemData].
## I might change it to hold an item directly, I haven't decided which would be better yet.

## Data properties for the [Item] held by this [ItemSlot], if there is one.
@export var item_data: ItemData:
	set(new_data):
		item_data = new_data
		if new_data:
			add_item()
		else:
			remove_item()

## The base [Item] scene.
var item_scene := preload("res://entities/items/item.tscn")
## The current [Item] held by this slot, or [param null] if it is empty.
var current_item: Item

func _ready() -> void:
	if item_data:
		add_item()

## Clears the current [Item] from the [ItemSlot], if one exists.
func remove_item() -> void:
	if current_item:
		current_item.queue_free()
		current_item = null

## Adds a new [Item] to the [ItemSlot] and populates it with the slot's held [ItemData].
func add_item() -> void:
	if not is_instance_valid(current_item):
		current_item = item_scene.instantiate()
		add_child(current_item)
	current_item.item_data = item_data
