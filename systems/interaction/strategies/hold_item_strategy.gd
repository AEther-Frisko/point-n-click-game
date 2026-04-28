class_name HoldItemStrategy extends InteractionStrategy

func _init() -> void:
	if not verb:
		verb = Verbs.take

func can_interact(context: InteractionContext) -> bool:
	return not context.is_holding_item()

func interact(context: InteractionContext) -> void:
	context.hold_item()
