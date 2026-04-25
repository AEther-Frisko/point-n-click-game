class_name GetItemStrategy extends InteractionStrategy

@export var item_data: ItemData

func interact(context: InteractionContext) -> void:
	context.add_item(item_data)
	context.take_item()
