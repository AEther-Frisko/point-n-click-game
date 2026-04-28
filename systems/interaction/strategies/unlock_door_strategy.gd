class_name UnlockDoorStrategy extends InteractionStrategy

func interact(context: InteractionContext) -> void:
	context.interactable.is_locked = false
	context.display_text("It's unlocked.")
