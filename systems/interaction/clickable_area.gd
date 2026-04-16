class_name ClickableArea extends Area2D

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
