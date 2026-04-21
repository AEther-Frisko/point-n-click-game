extends Control
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

## Displays input description text to the screen. If a show_time is included,
## The text will automatically fade after that number of seconds.
func display_description(desc: String, show_time: float = 0) -> void:
	# display text
	text_display.text = desc
	fade_node(text_display, Color.WHITE, 0.25)
	
	if show_time > 0:
		fade_timer.start(show_time)
		await fade_timer.timeout
		hide_description()

func hide_description() -> void:
	fade_node(text_display, Color.TRANSPARENT, 0.5)

## Fades screen to black, resets text display, then fades back
func transition_screen() -> void:
	fade_timer.stop()
	text_display.modulate = Color.TRANSPARENT
	
	screen_fade.visible = true
	fade_node(screen_fade, Color.WHITE, 0.5)
	
	await verify_tweened_node(screen_fade)
	
	fade_node(screen_fade, Color.TRANSPARENT, 0.5)
	await tween_finished
	screen_fade.visible = false

## awaits tween completion until the right [member node] triggers it.
func verify_tweened_node(node: CanvasItem) -> void:
	var tweened_node = await tween_finished
	if tweened_node != node:
		await verify_tweened_node(node)

func add_item(item: ItemData) -> void:
	# create an item preview that enters the player's inventory
	var item_preview = TextureRect.new()
	item_preview.position = get_viewport().get_mouse_position()
	item_preview.modulate = Color(1,1,1,0.5) # semi-transparent
	item_preview.texture = item.texture
	item_preview.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	item_preview.size = Vector2(64,64)
	self.add_child(item_preview)
	
	#tween animation to make preview move into inventory and then disappear
	var tween = get_tree().create_tween()
	var tween_goal = inventory.button.position + (inventory.button.size / 2)
	var tween_distance = item_preview.position.distance_to(tween_goal)
	var tween_time = tween_distance / 1200 # should I use this or a fixed time?
	tween.tween_property(item_preview, "position", tween_goal, tween_time)
	await tween.finished
	item_preview.queue_free()
	
	inventory.add_item(item)
	item_added.emit()
