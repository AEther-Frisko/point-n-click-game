class_name SequentialStrategy extends InteractionStrategy

@export var strategy_list: Array[InteractionStrategy]

func _init() -> void:
	if not verb:
		verb = strategy_list.front().verb

func interact(context: InteractionContext) -> void:
	for strategy in strategy_list:
		strategy.interact(context)
