class_name ExamineStrategy extends InteractionStrategy

@export_multiline var description: String

func interact(context: InteractionContext) -> void:
	context.display_text(description)
