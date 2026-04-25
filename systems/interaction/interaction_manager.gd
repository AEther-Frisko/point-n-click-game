class_name InteractionManager extends Node
## The main manager for all [Interactable]s in the game.
##
## Keeps track of [Interactable]s in the scene and manages how their interactions
## should affect the game. For example, changing the mouse cursor depending on
## what kind of [Interactable] is being hovered over.

## The parent of all GUI ([Control]) elements.
@onready var gui : GuiManager = %GUI

## The parent of all elements in the world ([Node2D]).
@onready var world : SceneManager = %World

## All [Interactable]s in the scene.
@onready var interactable_list : Array[Node]

## All [Interactable]s currently being hovered over by the mouse.
var hovered_area_list : Array[Node]

## Currently held [Item].
var held_item: Item = null

## Cursor [Texture] to load depending on the context.
@export var cursors := {
	"Default" : preload("res://shared/images/cursors/cur_default.png"),
	"Look" : preload("res://shared/images/cursors/cur_look.png"),
	"Walk" : preload("res://shared/images/cursors/cur_walk.png"),
	"Use" : preload("res://shared/images/cursors/cur_hand.png"),
	"Item" : preload("res://shared/images/cursors/cur_item.png")
}

func _ready() -> void:
	get_tree().current_scene.ready.connect(_on_scene_ready)
	world.room_loaded.connect(_on_scene_ready)

func _on_scene_ready() -> void:
	reset_interactables()
	update_interactables()

## Ensures any new [Interactable]s are added to [member interactable_list],
## and ones that no longer exist are removed.
func update_interactables() -> void:
	interactable_list.clear()
	# check for new [Interactable]s
	var new_interactables = get_tree().get_nodes_in_group("interactables")
	for interactable in new_interactables:
		add_interactable(interactable)

## Adds a new [Interactable] to [member interactable_list] and connects its signals.
func add_interactable(interactable: Node) -> void:
	interactable_list.append(interactable)
	if interactable.hover_started.is_connected(_on_hover_started):
		return
	interactable.hover_started.connect(_on_hover_started)
	interactable.hover_ended.connect(_on_hover_ended)
	if interactable is Interactable: # to skip over inventory
		interactable.clicked.connect(_on_clicked)

## Removes an [Interactable] from [member interactable_list].
func remove_interactable(interactable: Node) -> void:
	interactable_list.erase(interactable)

## Adds a new area [Node] to [member hovered_area_list] and updates the cursor accordingly.
func add_hovered_area(area: Node) -> void:
	hovered_area_list.append(area)
	set_cursor_by_type(area)

## Removes an area [Node] from [member hovered_area_list] and updates the cursor if necessary.
func remove_hovered_area(area: Node) -> void:
	hovered_area_list.erase(area)
	update_cursor()

## Clears tracked [member interactable_list] and [member hovered_area_list].
func reset_interactables() -> void:
	interactable_list.clear()
	hovered_area_list.clear()
	set_cursor("Default")

## Sets the mouse cursor to a specified [member cursors].
func set_cursor(new_cursor: String) -> void:
	Input.set_custom_mouse_cursor(cursors[new_cursor])

## Sets the mouse cursor based on the speciied [Node]'s type/group.
# TODO: Improve this? unsure about it still.
func set_cursor_by_type(area: Node) -> void:
	if held_item:
		set_cursor("Item")
	elif area is Button or area is Item:
		set_cursor("Use")
	elif area is Prop:
		if area.prop_data.held_item:
			set_cursor("Use")
		else:
			set_cursor("Look")
	elif area is Door:
		set_cursor("Walk")
	else:
		set_cursor("Default")

func update_cursor() -> void:
	if hovered_area_list.is_empty():
		if not held_item:
			set_cursor("Default")
		return
	set_cursor_by_type(hovered_area_list.back())

func _on_hover_started(area: Node) -> void:
	add_hovered_area(area)
	if area is Item:
		gui.display_text(area.item_data.item_name)

func _on_hover_ended(area: Node) -> void:
	remove_hovered_area(area)
	if area is Item:
		gui.hide_text()

func create_context() -> InteractionContext:
	var context = InteractionContext.new()
	context.manager = self
	context.gui = gui
	context.world = world
	return context

func _on_clicked(interactable: Interactable) -> void:
	if held_item: # temp until i set up action-switching better
		drop_held_item()
		update_cursor()
	elif interactable.current_interaction:
		var context = create_context()
		context.interactable = interactable
		interactable.current_interaction.interact(context)
		update_cursor()
	else:
		push_warning(interactable, " does not have an interaction attached.")

func drop_held_item() -> void:
	gui.drop_item(held_item)
	held_item = null

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("click"):
		return
	if held_item:
		drop_held_item()
		set_cursor("Default")
