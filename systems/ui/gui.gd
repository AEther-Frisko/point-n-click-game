extends Control

@onready var text_display: Label = %TextDisplay

func _ready() -> void:
	# text display is invisible until needed
	text_display.set_modulate(Color.TRANSPARENT)

## Uses the modulate property on a [CanvasItem] to tween between its current colour
## and the specified [param fade_color] (i.e. [constant Color.TRANSPARENT] makes the node fade out
## until it is invisible).
func fade_node(node: CanvasItem, fade_color: Color, fade_duration: float) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(node, "modulate", fade_color, fade_duration)

## Displays input description text to the screen for a limited time.
func display_description(desc: String) -> void:
	# timer configuration
	# should only create a timer if one doesn't exist
	var fade_timer = get_node_or_null("FadeTimer")
	if fade_timer == null:
		fade_timer = Timer.new()
		fade_timer.name = "FadeTimer"
		add_child(fade_timer)
	
	# display text
	text_display.text = desc
	fade_node(text_display, Color.WHITE, 0.25)
	
	fade_timer.start(3.0)
	await fade_timer.timeout
	
	# hide text
	fade_node(text_display, Color.TRANSPARENT, 0.5)
