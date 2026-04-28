class_name InteractionContext extends RefCounted
## Provides an [InteractionStrategy] with necessary references and functions
## to perform various actions.

var manager: InteractionManager
var gui: GuiManager
var world: SceneManager
var interactable: Interactable

func display_text(text: String, duration := 3.0) -> void:
	gui.display_text(text, duration)

func add_item(item_data: ItemData) -> void:
	# for some reason the context kills itself before the await goes through
	# unless I add this??
	var _test = self
	gui.add_item(item_data)
	await gui.item_added
	manager.update_interactables()

func take_item() -> void:
	if interactable is Prop:
		interactable.prop_data.held_item = null
		if interactable.prop_data.is_item:
			remove_interactable()

func hold_item() -> void:
	if interactable is Item:
		manager.held_item = interactable
		gui.hold_item(manager.held_item)

func is_holding_item() -> bool:
	return is_instance_valid(manager.held_item)

func get_held_item_data() -> ItemData:
	if not is_holding_item():
		return null
	return manager.held_item.item_data

func drop_held_item() -> void:
	gui.drop_item(manager.held_item)
	manager.held_item = null

func use_held_item() -> void:
	gui.use_item(manager.held_item)
	manager.held_item = null

func remove_interactable() -> void:
	manager.remove_hovered_area(interactable)
	interactable.queue_free()

func load_room(destination: String) -> void:
	var _test = self
	gui.transition_screen()
	await gui.verify_tweened_node(gui.screen_fade)
	world.load_room(destination)
