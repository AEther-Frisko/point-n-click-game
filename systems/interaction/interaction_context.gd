class_name InteractionContext extends RefCounted
## Provides an [InteractionStrategy] with necessary references and functions
## to perform various actions.

var manager: InteractionManager
var gui: GuiManager
var world: SceneManager
var interactable: Interactable

## Displays the input [String] to the screen via the [GuiManager].
func display_text(text: String, duration := 3.0) -> void:
	gui.display_text(text, duration)

## Adds an [ItemData] to the inventory via the [GuiManager].
func add_item(item_data: ItemData) -> void:
	# for some reason the context kills itself before the await goes through
	# unless I add this??
	var _test = self
	gui.add_item(item_data)
	await gui.item_added
	manager.update_interactables()

## Removes an [ItemData] from an [Interactable] that acts as a container.
func take_item() -> void:
	if interactable.container_data:
		interactable.container_data.held_item = null
		if interactable.container_data.is_item:
			remove_interactable()

## Sets a held [Item] in the [InteractionManager]
## and shows it via the [GuiManager].
func hold_item() -> void:
	if interactable is Item:
		manager.held_item = interactable
		gui.hold_item(manager.held_item)

## Helper for checking if there is a held [Item] via the [InteractionManager].
func is_holding_item() -> bool:
	return is_instance_valid(manager.held_item)

## Helper for getting the held [Item]'s data from the [InteractionManager].
func get_held_item_data() -> ItemData:
	if not is_holding_item():
		return null
	return manager.held_item.item_data

## Drops the current held [Item] via the [InteractionManager] and [GuiManager].
func drop_held_item() -> void:
	gui.drop_item(manager.held_item)
	manager.held_item = null

## Uses the current held [Item] via the [InteractionManager] and [GuiManager].
func use_held_item() -> void:
	gui.use_item(manager.held_item)
	manager.held_item = null

## Helper to get the [Interactable]'s locked state, if it has one.
func get_lock_state() -> bool:
	return interactable.get_lock_state()

## Helper to get the [Interactable]'s key item, if it has one.
## Used to unlock a locked [Interactable].
func get_key_item() -> ItemData:
	return interactable.get_key_item()

## Removes the [Interactable] from the [SceneTree].
func remove_interactable() -> void:
	manager.remove_hovered_area(interactable)
	interactable.queue_free()

## Loads a new room via the [SceneManager] and [GuiManager] (for screen transition).
func load_room(destination: String) -> void:
	var _test = self
	gui.transition_screen()
	await gui.verify_tweened_node(gui.screen_fade)
	world.load_room(destination)
