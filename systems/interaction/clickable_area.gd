class_name ClickableArea extends Area2D
## A region of 2D space that detects when it has been clicked.
##
## A special type of [Area2D] that looks for [InputEvent]s and signals if it is a mouse click.
## Meant to be attached to [Interactable]s, but can be used on its own as well.

## The attached [CollisionShape2D].
@onready var collision_shape = get_node_or_null("CollisionShape2D")

var is_hovered := false

## Emitted when the attached [CollisionShape2D] is clicked.
signal clicked()

func _ready() -> void:
	# create a default collision shape if there isn't one
	if not collision_shape:
		collision_shape = CollisionShape2D.new()
		collision_shape.set_shape(RectangleShape2D.new())
		add_child(collision_shape)
	
	mouse_entered.connect(_on_hover_start)
	mouse_exited.connect(_on_hover_end)

func _on_hover_start() -> void:
	is_hovered = true

func _on_hover_end() -> void:
	is_hovered = false

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("click"):
		return
	
	if is_hovered:
		get_viewport().set_input_as_handled()
		clicked.emit()
