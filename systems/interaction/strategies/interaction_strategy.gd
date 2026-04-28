class_name InteractionStrategy extends Resource
## Base class for different kinds of interaction actions that can be performed
## by an [Interactable] upon being clicked.

## Defines what type of interaction this is, such as the cursor type to use.
@export var verb: Verb

func can_interact(_context: InteractionContext) -> bool:
	return true

## Whatever actions to be performed when the [Interactable] is clicked.
func interact(_context: InteractionContext) -> void:
	pass
