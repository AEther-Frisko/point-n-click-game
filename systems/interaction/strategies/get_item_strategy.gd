class_name GetItemStrategy extends InteractionStrategy

@export var item_data: ItemData

func _init() -> void:
	if not verb:
		verb = Verbs.take

func can_interact(_context: InteractionContext) -> bool:
	return is_instance_valid(item_data)

func interact(context: InteractionContext) -> void:
	context.add_item(item_data)
	context.take_item()
	item_data = null
