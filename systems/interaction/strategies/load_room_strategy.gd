class_name LoadRoomStrategy extends InteractionStrategy

@export var destination: String

func _init() -> void:
	if not verb:
		verb = Verbs.walk

func interact(context: InteractionContext) -> void:
	context.load_room(destination)
