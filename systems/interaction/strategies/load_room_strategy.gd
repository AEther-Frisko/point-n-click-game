class_name LoadRoomStrategy extends InteractionStrategy

@export var destination: String

func _init() -> void:
	if not verb:
		verb = Verbs.walk

func can_interact(context: InteractionContext) -> bool:
	if context.interactable is Door:
		return not context.interactable.is_locked
	else:
		return true

func interact(context: InteractionContext) -> void:
	context.load_room(destination)
