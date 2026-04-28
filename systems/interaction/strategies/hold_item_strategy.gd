class_name HoldItemStrategy extends InteractionStrategy

func _init() -> void:
	if not verb:
		verb = Verbs.take

func interact(context: InteractionContext) -> void:
	context.hold_item()
