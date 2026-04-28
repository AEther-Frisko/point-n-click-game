class_name Interactable extends CanvasItem
## The base [Interactable] class, which holds basic interaction functionality.
##
## Uses a [ClickableArea] to recieve mouse hovering and clicks,
## and sends out signals depending on what is recieved.

## Possible Interactions this can perform.
@export var interaction_list: Array[InteractionStrategy]

## Emitted when the attached [ClickableArea] is clicked on.
signal clicked()

## Emitted when the attached [ClickableArea] is hovered over by the mouse.
signal hover_started(node: Node)

## Emitted when the attached [ClickableArea] is no longer being hovered over by the mouse.
signal hover_ended(node: Node)

## The attached [ClickableArea].
@onready var clickable_area = get_node_or_null("ClickableArea")

func _ready() -> void:
	add_to_group("interactables")
	
	# create clickable area if there isn't one
	if not clickable_area:
		clickable_area = ClickableArea.new()
		add_child(clickable_area)
	
	# connect clickable area signals
	clickable_area.clicked.connect(_on_clicked)
	clickable_area.mouse_entered.connect(_on_hover_start)
	clickable_area.mouse_exited.connect(_on_hover_end)

## Creates default [InteractionStrategy] [Array] that can be overwritten.
func create_interactions() -> void:
	pass

func get_valid_interactions(context: InteractionContext) -> Array[InteractionStrategy]:
	var result: Array[InteractionStrategy]
	for interaction in interaction_list:
		if interaction.can_interact(context):
			result.append(interaction)
	return result

## Indicates that this [Interactable] has been clicked.
func _on_clicked() -> void:
	clicked.emit(self)

## Indicates that the mouse is hovering over this [Interactable].
func _on_hover_start() -> void:
	hover_started.emit(self)

## Indicates that the mouse has stopped hovering over this [Interactable].
func _on_hover_end() -> void:
	hover_ended.emit(self)
