class_name ClickableArea extends Area2D
## A region of 2D space that detects when it has been clicked.
##
## A special type of [Area2D] that looks for [InputEvent]s and signals if it is a mouse click.
## Meant to be attached to [Interactable]s, but can be used on its own as well.

## Emitted when the attached [CollisionShape2D] is clicked.
signal clicked()

## The attached [CollisionShape2D].
@onready var collision_shape = get_node_or_null("CollisionShape2D")

func _ready() -> void:
	# create a default collision shape if there isn't one
	if not collision_shape:
		collision_shape = CollisionShape2D.new()
		collision_shape.set_shape(RectangleShape2D.new())
		add_child(collision_shape)

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		get_viewport().set_input_as_handled()
		clicked.emit()
