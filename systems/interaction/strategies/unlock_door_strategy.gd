class_name UnlockDoorStrategy extends InteractionStrategy

func interact(context: InteractionContext) -> void:
	context.interactable.toggle_lock(false)
	context.display_text("It's unlocked.")
