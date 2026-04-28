class_name Item extends Interactable
## A type of [Interactable] that is stored in the inventory.
##
## Since this one is a [Control] node, it doesn't use the standard [ClickableArea]
## for its inputs. Instead, it uses the [Control]'s built-in click detection.
## This is mostly to make aligning with other [Control] nodes easier.

## The [TextureRect] node to visually display the [Item].
@onready var texture_rect := get_node_or_null("TextureRect")

## Replacement for the [ClickableArea] that plays nice with [Control] nodes.
@onready var area_container: Control = $AreaContainer

## Data properties for the [Item].
@export var item_data: ItemData:
	set(new_data):
		item_data = new_data
		if new_data.texture:
			update_texture(new_data.texture)

func _ready() -> void:
	add_to_group("interactables")
	
	if not texture_rect:
		texture_rect = TextureRect.new()
		add_child(texture_rect)
	if not item_data:
		item_data = ItemData.new()
	item_data.texture_changed.connect(update_texture.bind(item_data.texture))
	
	create_interactions()
	
	area_container.mouse_entered.connect(_on_hover_start)
	area_container.mouse_exited.connect(_on_hover_end)
	area_container.gui_input.connect(_on_input)

func create_interactions() -> void:
	if not interaction_list.is_empty():
		return # allows overriding of default interactions
	interaction_list.append(HoldItemStrategy.new())

## Updates the [member texture_rect]'s [Texture2D] to match the current [ItemData].
func update_texture(new_texture: Texture2D) -> void:
	texture_rect.texture = new_texture

## Triggered when the [Item] detects user input, but only cares about mouse clicks.
func _on_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		get_viewport().set_input_as_handled()
		clicked.emit(self)

## Triggered when the mouse hovers over the [Item].
func _on_hover_start() -> void:
	hover_started.emit(self)

## Triggered when the mouse stops hovering over the [Item].
func _on_hover_end() -> void:
	hover_ended.emit(self)
