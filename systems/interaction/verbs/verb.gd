class_name Verb extends Resource
## Defines what cursor to use when an [Interactable] is hovered over,
## and determines the priority of its parent [InteractionStrategy] when
## picking between multiple.

@export var name: String
@export var cursor: Texture2D
@export var priority: int = 0
