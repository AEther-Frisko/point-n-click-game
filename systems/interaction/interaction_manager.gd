extends Node
## The main manager for all [Interactable]s in the game.
##
## Keeps track of [Interactable]s in the scene and manages how their interactions
## should affect the game. For example, changing the mouse cursor depending on
## what kind of [Interactable] is being hovered over.

## All [Interactable]s in the scene.
@onready var interactable_list : Array[Node]

## The parent of all GUI ([Control]) elements.
@onready var gui := %GUI

## The parent of all elements in the world ([Node2D]).
@onready var world := %World

## Currently loaded room scene.
var current_room : Node2D

## All [Interactable]s currently being hovered over by the mouse.
var hovered_area_list : Array[Node]

var holding_item := false

## Cursor [Texture] to load depending on the context.
@export var cursors := {
	"Default" : preload("res://shared/images/cursors/cur_default.png"),
	"Look" : preload("res://shared/images/cursors/cur_look.png"),
	"Walk" : preload("res://shared/images/cursors/cur_walk.png"),
	"Use" : preload("res://shared/images/cursors/cur_hand.png"),
	"Item" : preload("res://shared/images/cursors/cur_item.png")
}

func _ready() -> void:
	load_room("room")
	get_tree().current_scene.ready.connect(_on_scene_ready)

func _on_scene_ready() -> void:
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
	
	# type-dependent connections
	if interactable is Prop:
		interactable.clicked.connect(_on_prop_clicked)
	elif interactable is Door:
		interactable.clicked.connect(_on_door_clicked)
	elif interactable is Item:
		interactable.clicked.connect(_on_item_clicked)

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
	if hovered_area_list.is_empty():
		if not holding_item:
			set_cursor("Default")
		return
	set_cursor_by_type(hovered_area_list.back())

## Sets the mouse cursor to a specified [member cursors].
func set_cursor(new_cursor: String) -> void:
	Input.set_custom_mouse_cursor(cursors[new_cursor])

## Sets the mouse cursor based on the speciied [Node]'s type/group.
# TODO: Improve this? unsure about it still.
func set_cursor_by_type(area: Node) -> void:
	if holding_item:
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

## Clears tracked [member interactable_list] and [member hovered_area_list].
func reset_interactables() -> void:
	interactable_list.clear()
	hovered_area_list.clear()
	set_cursor("Default")

# might move the room loading/unloading into a separate manager later
# since it's not directly interaction-related
## Unloads the [member current_room] from the [SceneTree].
func unload_room() -> void:
	if holding_item:
		gui.drop_item()
		holding_item = false
	if is_instance_valid(current_room):
		current_room.queue_free()
	reset_interactables()
	if gui.inventory:
		gui.inventory.toggle_inventory(false)
	current_room = null

## Loads a new room [PackedScene] according to the specified destination [String].
func load_room(destination: String) -> void:
	unload_room()
	var room_path := "res://entities/rooms/%s.tscn" % destination
	var new_room = load(room_path)
	if new_room:
		current_room = new_room.instantiate()
		current_room.ready.connect(_on_scene_ready)
		world.add_child(current_room)

func _on_hover_started(area: Node) -> void:
	add_hovered_area(area)
	if area is Item:
		gui.display_text(area.item_data.item_name)

func _on_hover_ended(area: Node) -> void:
	remove_hovered_area(area)
	if area is Item:
		gui.hide_text()

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("click"):
		return
	if holding_item:
		gui.drop_item()
		holding_item = false
		set_cursor("Default")

## If the [Prop] has an item, that item is picked up. Otherwise,
## the [Item]'s description is displayed.
func _on_prop_clicked(input, prop: Prop = null) -> void:
	if holding_item:
		# temp for testing
		gui.display_text("Put item into this thing, I guess?", 3.0)
		prop.prop_data.held_item = gui.held_item.item_data
		gui.use_held_item()
		holding_item = false
		set_cursor_by_type(hovered_area_list.back())
		update_interactables()
		return
	
	if input is String:
		gui.display_text(input, 3.0)
	elif input is ItemData:
		gui.add_item(input)
		prop.prop_data.held_item = null
		if prop.prop_data.is_item:
			remove_hovered_area(prop)
			prop.queue_free()
		else:
			set_cursor("Look")
		await gui.item_added
		update_interactables()

## Initiates a room transition according to the clicked [Door]'s destination.
func _on_door_clicked(destination: String) -> void:
	if holding_item:
		# temp for testing
		gui.display_text("This item doesn't work on this door...")
		gui.drop_item()
		holding_item = false
		set_cursor_by_type(hovered_area_list.back())
		return
	
	gui.transition_screen()
	await gui.verify_tweened_node(gui.screen_fade)
	load_room(destination)

func _on_item_clicked(item: Item) -> void:
	if holding_item:
		# temp for testing
		gui.display_text("These items can't combine...")
		gui.drop_item()
		holding_item = false
		set_cursor_by_type(hovered_area_list.back())
		return
	
	gui.hold_item(item)
	holding_item = true
	set_cursor("Item")
