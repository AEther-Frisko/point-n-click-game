class_name LoadRoomStrategy extends InteractionStrategy

@export var destination: String

func _init() -> void:
	if not verb:
		verb = Verbs.walk

func can_interact(context: InteractionContext) -> bool:
	return not context.get_lock_state()

func interact(context: InteractionContext) -> void:
	var dest = destination
	if not dest:
		dest = context.interactable.destination
	context.load_room(dest)
