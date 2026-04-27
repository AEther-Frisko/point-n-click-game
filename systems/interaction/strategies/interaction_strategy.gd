class_name InteractionStrategy extends Resource
## Base class for different kinds of interaction actions that can be performed
## by an [Interactable] upon being clicked.

## Whatever actions to be performed when the [Interactable] is clicked.
func interact(_context: InteractionContext) -> void:
	pass
