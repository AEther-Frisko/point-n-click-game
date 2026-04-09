extends Control

@onready var text_display: Label = %TextDisplay 
@onready var props = get_tree().get_nodes_in_group("props")

func _ready() -> void:
	# text display is invisible until needed
	text_display.set_modulate(Color.TRANSPARENT)

# Keeps all prop signals connected to the GUI, even as they are added/removed.
# But it's kinda ugly so I might be changing it later
func _process(_delta: float) -> void:
	var current_props = get_tree().get_nodes_in_group("props")
	if props != current_props:
		props = current_props
		for prop in props:
			if !prop.prop_clicked.is_connected(_on_prop_clicked):
				prop.prop_clicked.connect(_on_prop_clicked)

## Handles GUI changes that should occur when a Prop is clicked.
func _on_prop_clicked(desc: String) -> void:
	# timer configuration
	# should only create a timer if one doesn't exist
	var fade_timer = get_node_or_null("FadeTimer")
	if fade_timer == null:
		fade_timer = Timer.new()
		fade_timer.name = "FadeTimer"
		add_child(fade_timer)
	
	# display prop text
	text_display.text = desc
	fade_node(text_display, Color.WHITE, 0.25)
	
	fade_timer.start(3.0)
	await fade_timer.timeout
	
	# hide prop text
	fade_node(text_display, Color.TRANSPARENT, 0.5)

## Uses the modulate property on a [CanvasItem] to tween between its current colour
## and the specified [param fade_color] (i.e. [constant Color.TRANSPARENT] makes the node fade out
## until it is invisible).
func fade_node(node: CanvasItem, fade_color: Color, fade_duration: float) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(node, "modulate", fade_color, fade_duration)
