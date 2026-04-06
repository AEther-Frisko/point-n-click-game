extends Control


func _ready() -> void:
	# definitely want to change this later, just testing
	var prop = get_node("../World/Prop")
	var prop2 = get_node("../World/Prop2")
	prop.prop_clicked.connect(_on_prop_clicked)
	prop2.prop_clicked.connect(_on_prop_clicked)

func _on_prop_clicked(desc: String) -> void:
	var label = get_node("MarginContainer/Label")
	
	# timer configuration
	# should only create a timer if one doesn't exist
	var fade_timer = get_node_or_null("FadeTimer")
	if fade_timer == null:
		fade_timer = Timer.new()
		fade_timer.name = "FadeTimer"
		add_child(fade_timer)
	
	# display prop text
	label.text = desc
	fade_node(label, Color.WHITE, 0.25)
	
	fade_timer.start(3.0)
	await fade_timer.timeout
	
	# hide prop text
	fade_node(label, Color.TRANSPARENT, 0.5)

## Uses the modulate property on a CanvasItem to create a fade effect.
##
## node: node to be faded to another colour
## fade_color: final colour of the node (i.e. Color.TRANSPARENT hides a node)
func fade_node(node: CanvasItem, fade_color: Color, fade_duration: float) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(node, "modulate", fade_color, fade_duration)
