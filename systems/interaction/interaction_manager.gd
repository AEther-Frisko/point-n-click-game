extends Node

## All interactables in the scene.
@onready var interactables := get_tree().get_nodes_in_group("interactables")

@onready var gui := %GUI
@onready var world := %World

var current_room : Node2D
var inventory_connected := false # this feels so gross and hacky but whatever

## All interactables currently being hovered over by the mouse.
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

## Ensures any new interactable [Node]s are added to [member interactables],
## and ones that no longer exist are removed.
func update_interactables(new_interactables: Array[Node]) -> void:
	# connect inventory signals, if necessary
	if not inventory_connected:
		add_interactable(gui.inventory)
		inventory_connected = true
	
	# check for interactables that no longer exist
	for interactable in interactables:
		if not new_interactables.has(interactable):
			remove_interactable(interactable)
	
	# check for new interactables
	for interactable in new_interactables:
		if not interactables.has(interactable):
			add_interactable(interactable)

## Adds a new interactable [Node] to [member interactables] and connects its signals.
func add_interactable(interactable: Node) -> void:
	interactables.append(interactable)
	interactable.hover_started.connect(add_hovered_area)
	interactable.hover_ended.connect(remove_hovered_area)
	
	# type-dependent connections
	var groups := interactable.get_groups()
	if groups.has("props"):
		interactable.clicked.connect(_on_prop_clicked)
	elif groups.has("doors"):
		interactable.clicked.connect(_on_door_clicked)

## Remove an interactable [Node] from [member interactables].
func remove_interactable(interactable: Node) -> void:
	interactables.erase(interactable)

## Adds a new area [Node] to [member hovered_areas] and updates the cursor accordingly.
func add_hovered_area(area: Node) -> void:
	hovered_areas.append(area)
	set_cursor_by_group(area)

## Removes an area [Node] from [member hovered_areas] and updates the cursor if necessary.
func remove_hovered_area(area: Node) -> void:
	hovered_areas.erase(area)
	if hovered_areas.is_empty():
		set_cursor("Default")
		return
	set_cursor_by_group(hovered_areas.back())

## Sets the mouse cursor to a specified [member cursors].
func set_cursor(new_cursor: String) -> void:
	Input.set_custom_mouse_cursor(cursors[new_cursor])

## Sets the mouse cursor based on the speciied [Node]'s group.
func set_cursor_by_group(area: Node) -> void:
	# special case
	if area == gui.inventory:
		set_cursor("Use")
		return
	
	var groups := area.get_groups()
	if groups.has("props"):
		set_cursor("Look")
	elif groups.has("doors"):
		set_cursor("Walk")

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

func load_room(destination: String) -> void:
	unload_room()
	var room_path := "res://entities/rooms/%s.tscn" % destination
	var new_room = load(room_path)
	if new_room:
		current_room = new_room.instantiate()
		world.add_child(current_room)

func _on_prop_clicked(desc: String) -> void:
	gui.display_description(desc)

func _on_door_clicked(destination: String) -> void:
	gui.transition_screen()
	await gui.verify_tweened_node(gui.screen_fade)
	load_room(destination)
