class_name UseItemStrategy extends InteractionStrategy

@export var expected_item: ItemData

@export var success: InteractionStrategy
@export var failure: InteractionStrategy

func _init() -> void:
	if not verb:
		verb = Verbs.use
	if not failure:
		failure = ExamineStrategy.new()
		failure.description = "That didn't work."

func can_interact(context: InteractionContext) -> bool:
	return context.is_holding_item()

func interact(context: InteractionContext) -> void:
	if expected_item == context.get_held_item_data():
		context.use_held_item()
		success.interact(context)
	else:
		context.drop_held_item()
		failure.interact(context)
