extends Control

@onready var text_display: Label = %TextDisplay
@onready var screen_fade: ColorRect = $ScreenFade
@onready var fps_display: Label = %FpsDisplay

var fade_timer: Timer

signal tween_finished(node: CanvasItem)

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
	var tween = get_tree().create_tween()
	tween.finished.connect(_on_tween_finished.bind(node))
	tween.tween_property(node, "modulate", fade_color, fade_duration)

func _on_tween_finished(node: CanvasItem) -> void:
	tween_finished.emit(node)

## Displays input description text to the screen for a limited time.
func display_description(desc: String) -> void:
	# display text
	text_display.text = desc
	fade_node(text_display, Color.WHITE, 0.25)
	
	fade_timer.start(3.0)
	await fade_timer.timeout
	
	# hide text
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
