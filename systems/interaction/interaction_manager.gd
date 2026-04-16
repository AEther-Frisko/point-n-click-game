extends Node

## All [Interactable]s in the scene.
@onready var interactables := get_tree().get_nodes_in_group("interactables")

## The parent of all GUI ([Control]) elements.
@onready var gui := %GUI

## The parent of all elements in the world ([Node2d]).
@onready var world := %World

## Currently loaded room scene.
var current_room : Node2D

## All [Interactable]s currently being hovered over by the mouse.
var hovered_areas : Array[Node]

## Cursor [Texture] to load depending on the context.
@export var cursors := {
	"Default" : preload("res://shared/images/cursors/cur_default.png"),
	"Look" : preload("res://shared/images/cursors/cur_look.png"),
	"Walk" : preload("res://shared/images/cursors/cur_walk.png"),
	"Use" : preload("res://shared/images/cursors/cur_hand.png")
}

func _ready() -> void:
	load_room("room")

func _process(_delta: float) -> void:
	# check if all interactables in scene are accounted for
	var current_interactables = get_tree().get_nodes_in_group("interactables")
	if current_interactables != interactables:
		update_interactables(current_interactables)

## Ensures any new [Interactable]s are added to [member interactables],
## and ones that no longer exist are removed.
func update_interactables(new_interactables: Array[Node]) -> void:
	# check for [Interactable]s that no longer exist
	for interactable in interactables:
		if not new_interactables.has(interactable):
			remove_interactable(interactable)
	
	# check for new [Interactable]s
	for interactable in new_interactables:
		if not interactables.has(interactable):
			add_interactable(interactable)

## Adds a new [Interactable] to [member interactables] and connects its signals.
func add_interactable(interactable: Node) -> void:
	interactables.append(interactable)
	if interactable.hover_started.is_connected(add_hovered_area):
		return
	interactable.hover_started.connect(add_hovered_area)
	interactable.hover_ended.connect(remove_hovered_area)
	
	# type-dependent connections
	var groups := interactable.get_groups()
	if groups.has("props"):
		interactable.clicked.connect(_on_prop_clicked)
	elif groups.has("doors"):
		interactable.clicked.connect(_on_door_clicked)
	elif groups.has("items"):
		interactable.clicked.connect(_on_item_clicked)

## Removes an [Interactable] from [member interactables].
func remove_interactable(interactable: Node) -> void:
	interactables.erase(interactable)

## Adds a new area [Node] to [member hovered_areas] and updates the cursor accordingly.
func add_hovered_area(area: Node) -> void:
	hovered_areas.append(area)
	set_cursor_by_type(area)

## Removes an area [Node] from [member hovered_areas] and updates the cursor if necessary.
func remove_hovered_area(area: Node) -> void:
	hovered_areas.erase(area)
	if hovered_areas.is_empty():
		set_cursor("Default")
		return
	set_cursor_by_type(hovered_areas.back())

## Sets the mouse cursor to a specified [member cursors].
func set_cursor(new_cursor: String) -> void:
	Input.set_custom_mouse_cursor(cursors[new_cursor])

## Sets the mouse cursor based on the speciied [Node]'s type/group.
func set_cursor_by_type(area: Node) -> void:
	# special cases
	match area.get_class():
		"Button":
			set_cursor("Use")
		"PanelContainer":
			set_cursor("Default")
	
	var groups := area.get_groups()
	if groups.has("props"):
		set_cursor("Look")
	elif groups.has("doors"):
		set_cursor("Walk")
	elif groups.has("items"):
		set_cursor("Use")

## Clears tracked [member interactables] and [member hovered_areas].
func reset_interactables() -> void:
	interactables.clear()
	hovered_areas.clear()
	set_cursor("Default")

# might move the room loading/unloading into a separate manager later
# since it's not directly interaction-related
## Unloads the [member current_room] from the [SceneTree].
func unload_room() -> void:
	if is_instance_valid(current_room):
		current_room.queue_free()
	reset_interactables()
	current_room = null

## Loads a new room [PackedScene] according to the specified destination [String].
func load_room(destination: String) -> void:
	unload_room()
	var room_path := "res://entities/rooms/%s.tscn" % destination
	var new_room = load(room_path)
	if new_room:
		current_room = new_room.instantiate()
		world.add_child(current_room)

## Signals to the [member gui] to display the clicked [Prop]'s description to the screen.
func _on_prop_clicked(desc: String) -> void:
	gui.display_description(desc)

## Initiates a room transition according to the clicked [Door]'s destination.
func _on_door_clicked(destination: String) -> void:
	gui.transition_screen()
	await gui.verify_tweened_node(gui.screen_fade)
	load_room(destination)

# this is temp for testing, will flesh out later
func _on_item_clicked(text: String) -> void:
	gui.display_description(text)
