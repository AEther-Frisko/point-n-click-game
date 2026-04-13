extends Node

## All interactables in the scene.
@onready var interactables := get_tree().get_nodes_in_group("interactables")

## All interactables currently being hovered over by the mouse.
var hovered_areas : Array[Node]

## Cursor [Texture] to load depending on the context.
var cursors := {
	"Default" : null,
	"Examine" : load("res://test_cursor.png")
}

func _process(_delta: float) -> void:
	# check if all interactables in scene are accounted for
	var current_interactables = get_tree().get_nodes_in_group("interactables")
	if current_interactables != interactables:
		update_interactables(current_interactables)

## Ensures any new interactable [Node]s are added to [member interactables].
func update_interactables(new_interactables: Array[Node]) -> void:
	for interactable in new_interactables:
		if !interactables.has(interactable):
			add_interactable(interactable)

## Adds a new interactable [Node] to the [Array] and connects its signals.
func add_interactable(interactable: Node) -> void:
	interactables.append(interactable)
	interactable.hover_started.connect(add_hovered_area)
	interactable.hover_ended.connect(remove_hovered_area)

## Adds a new area [Node] to [member hovered_areas] and updates the cursor accordingly.
func add_hovered_area(area: Node) -> void:
	hovered_areas.append(area)
	var groups := area.get_groups()
	if groups.has("props"):
		set_cursor("Examine")

## Removes an area [Node] from [member hovered_areas] and updates the cursor if necessary.
func remove_hovered_area(area: Node) -> void:
	hovered_areas.erase(area)
	if hovered_areas.is_empty():
		set_cursor("Default")

## Sets the mouse cursor to a specified [member cursors].
func set_cursor(new_cursor: String) -> void:
	Input.set_custom_mouse_cursor(cursors[new_cursor])
