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

func _ready() -> void:
	get_tree().current_scene.ready.connect(_on_scene_ready)
	world.room_loaded.connect(_on_scene_ready)

func _on_scene_ready() -> void:
	reset_interactables()
	update_interactables()
	add_interactable(gui.inventory)

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
	if interactable is Interactable: # skips inventory
		interactable.clicked.connect(_on_clicked)

## Removes an [Interactable] from [member interactable_list].
func remove_interactable(interactable: Node) -> void:
	interactable_list.erase(interactable)

## Adds a new area [Node] to [member hovered_area_list]
## and updates the cursor to match.
func add_hovered_area(area: Node) -> void:
	hovered_area_list.append(area)
	if area is Button: # might change this later it's a bit hacky
		Input.set_custom_mouse_cursor(Verbs.take.cursor)
		return
	update_cursor()

## Removes an area [Node] from [member hovered_area_list]
## and updates the cursor to match.
func remove_hovered_area(area: Node) -> void:
	hovered_area_list.erase(area)
	update_cursor()

## Clears tracked [member interactable_list] and [member hovered_area_list].
func reset_interactables() -> void:
	interactable_list.clear()
	hovered_area_list.clear()
	update_cursor()

## Updates the mouse cursor's appearance based on game state.
func update_cursor() -> void:
	if held_item:
		Input.set_custom_mouse_cursor(Verbs.hold_item.cursor)
		return
	
	if hovered_area_list.is_empty():
		Input.set_custom_mouse_cursor(Verbs.default.cursor)
		return
	
	if hovered_area_list.back() is Interactable:
		set_cursor_by_verb(hovered_area_list.back())
	else:
		Input.set_custom_mouse_cursor(Verbs.default.cursor)

## Sets the mouse cursor based on the specified [Interactable]'s [Verb].
func set_cursor_by_verb(area: Interactable) -> void:
	var context = create_context(area)
	var valid_list = area.get_valid_interactions(context)
	var best = choose_best_interaction(valid_list)
	if best:
		Input.set_custom_mouse_cursor(best.verb.cursor)
	else:
		Input.set_custom_mouse_cursor(Verbs.default.cursor)

func _on_hover_started(area: Node) -> void:
	add_hovered_area(area)
	if area is Item:
		gui.display_text(area.item_data.item_name)

func _on_hover_ended(area: Node) -> void:
	remove_hovered_area(area)
	if area is Item:
		gui.hide_text()

## Creates an [InteractionContext] for an [Interactable] to make use of.
func create_context(interactable: Interactable) -> InteractionContext:
	var context = InteractionContext.new()
	context.manager = self
	context.gui = gui
	context.world = world
	context.interactable = interactable
	return context

## Sorts the input [InteractionStrategy] [Array] by the priority level of each.
## Returns the highest priority option.
func choose_best_interaction(interaction_list: Array[InteractionStrategy]) -> InteractionStrategy:
	if interaction_list.is_empty():
		return null
	
	interaction_list.sort_custom(
		func(a,b):
			return a.verb.priority > b.verb.priority
	)
	return interaction_list.front()

func _on_clicked(interactable: Interactable) -> void:
	if not interactable.interaction_list.is_empty():
		var context = create_context(interactable)
		var valid_list = interactable.get_valid_interactions(context)
		var best = choose_best_interaction(valid_list)
		if best:
			best.interact(context)
		update_cursor()
	else:
		push_warning(interactable, " does not have any interactions attached.")

func drop_held_item() -> void:
	gui.drop_item(held_item)
	held_item = null

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("click"):
		return
	if held_item:
		drop_held_item()
		update_cursor()
