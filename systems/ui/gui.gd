class_name GuiManager extends Control
## The main controller for all GUI functionality.
##
## Manages visual changes such as displaying text to the screen, and screen transitions.

## [Label] for displaying interaction text.
@onready var text_display: Label = %TextDisplay

## [ColorRect] for creating a screen fade effect.
@onready var screen_fade: ColorRect = $ScreenFade

## [Label] for displaying the program's current FPS, mostly for debug purposes.
@onready var fps_display: Label = %FpsDisplay

## Parent of the inventory scene.
@onready var inventory: Control = %Inventory

## Timer for certain fade effects.
var fade_timer: Timer

## Current active fade tween.
var fade_tween: Tween = null

## Visible preview of an [Item].
var held_item_preview: TextureRect = null

## Emitted when a tween finishes on a [CanvasItem].
signal tween_finished(node: CanvasItem)

## Emitted when a new [Item] is added to the attached inventory.
signal item_added()

func _ready() -> void:
	# text display is invisible until needed
	text_display.set_modulate(Color.TRANSPARENT)
	screen_fade.set_modulate(Color.TRANSPARENT)
	screen_fade.visible = false
	
	# create timer for fade effects
	fade_timer = Timer.new()
	fade_timer.name = "FadeTimer"
	add_child(fade_timer)

func _process(_delta: float) -> void:
	fps_display.text = "FPS: " + str(Engine.get_frames_per_second())
	if held_item_preview:
		held_item_preview.position = get_viewport().get_mouse_position() + Vector2(20,20)

## Displays input text to the screen. If a show_time is included,
## The text will automatically fade after that number of seconds.
func display_text(text: String, show_time: float = 0) -> void:
	# display text
	text_display.text = text
	fade_node(text_display, Color.WHITE, 0.25)
	
	if show_time > 0:
		fade_timer.start(show_time)
		await fade_timer.timeout
		hide_text()

func hide_text() -> void:
	fade_node(text_display, Color.TRANSPARENT, 0.5)

## Fades screen to black, resets ui elements, then fades back
func transition_screen() -> void:
	fade_timer.stop()
	
	text_display.modulate = Color.TRANSPARENT
	toggle_inventory_panel(false)
	
	screen_fade.visible = true
	fade_node(screen_fade, Color.WHITE, 0.5)
	
	await verify_tweened_node(screen_fade)
	
	fade_node(screen_fade, Color.TRANSPARENT, 0.5)
	await tween_finished
	screen_fade.visible = false

## Uses the modulate property on a [CanvasItem] to tween between its current colour
## and the specified [param fade_color] (i.e. [constant Color.TRANSPARENT] makes the node fade out
## until it is invisible).
func fade_node(node: CanvasItem, fade_color: Color, fade_duration: float) -> void:
	if fade_tween:
		fade_tween.kill()
	fade_tween = get_tree().create_tween()
	fade_tween.finished.connect(_on_tween_finished.bind(node))
	fade_tween.tween_property(node, "modulate", fade_color, fade_duration)

## Indicates when a specified [CanvasItem] has finished its tween animation.
func _on_tween_finished(node: CanvasItem) -> void:
	tween_finished.emit(node)

## Awaits tween completion until the right [member node] triggers it.
func verify_tweened_node(node: CanvasItem) -> void:
	var tweened_node = await tween_finished
	if tweened_node != node:
		await verify_tweened_node(node)

## Uses a [Tween] to move an item preview ([TextureRect]) to the [member inventory]'s button.
func tween_item_to_inventory(item: TextureRect):
	var tween = get_tree().create_tween()
	var tween_goal = inventory.button.position + (inventory.button.size / 2)
	var tween_distance = item.position.distance_to(tween_goal)
	var tween_time = tween_distance / 1200 # should I use this or a fixed time?
	tween.tween_property(item, "position", tween_goal, tween_time)
	await tween.finished
	item.queue_free()

## Adds an [Item] to the inventory, including associated visual effects.
func add_item(item_data: ItemData) -> void:
	# create an item preview that enters the player's inventory
	var item_preview = create_item_preview(item_data)
	item_preview.modulate = Color(1,1,1,0.5) # semi-transparent
	
	#tween animation to make preview move into inventory and then disappear
	await tween_item_to_inventory(item_preview)
	
	inventory.add_item_data(item_data)
	item_added.emit()

## Visual changes to show the player is holding an [Item].
func hold_item(item: Item) -> void:
	# create preview of item to follow the mouse
	held_item_preview = create_item_preview(item.item_data)
	
	# hide item in inventory
	inventory.hide_item(item)

## Visual changes to show the held [Item] has been dropped and returned to the inventory.
func drop_item(item: Item) -> void:
	held_item_preview.queue_free()
	inventory.show_item(item)

## Removes the held [Item] from the inventory and the visual item preview. 
func use_item(item: Item) -> void:
	inventory.remove_item_data(item.item_data)
	held_item_preview.queue_free()

## Creates an [Item] preview at the mouse cursor.
func create_item_preview(item_data: ItemData) -> TextureRect:
	var item_preview := TextureRect.new()
	item_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	item_preview.position = get_viewport().get_mouse_position()
	item_preview.texture = item_data.texture
	item_preview.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	item_preview.size = Vector2(64,64)
	self.add_child(item_preview)
	return item_preview

## Tells the inventory panel to toggle its visibility state.
func toggle_inventory_panel(visibility: bool) -> void:
	if inventory:
		inventory.toggle_inventory(visibility)
