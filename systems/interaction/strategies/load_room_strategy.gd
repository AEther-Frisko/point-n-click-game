class_name LoadRoomStrategy extends InteractionStrategy

@export var destination: String

func interact(context: InteractionContext) -> void:
	context.load_room(destination)
