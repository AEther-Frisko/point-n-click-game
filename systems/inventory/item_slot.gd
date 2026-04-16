class_name ItemSlot extends PanelContainer

@export var item_data: ItemData:
	set(new_data):
		item_data = new_data
		if new_data:
			add_item()
		else:
			remove_item()

var item_scene := preload("res://entities/items/item.tscn")
var current_item: Item

func _ready() -> void:
	if item_data:
		add_item()

func remove_item() -> void:
	current_item.queue_free()
	current_item = null

func add_item() -> void:
	if current_item:
		remove_item()
	current_item = item_scene.instantiate()
	current_item.item_data = item_data
	add_child(current_item)
