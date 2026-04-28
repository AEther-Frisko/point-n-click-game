class_name ExamineStrategy extends InteractionStrategy

@export_multiline var description: String

func _init() -> void:
	if not verb:
		verb = Verbs.look

func interact(context: InteractionContext) -> void:
	context.display_text(description)
