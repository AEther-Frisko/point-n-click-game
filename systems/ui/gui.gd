extends Control


func _ready() -> void:
	var prop = get_node("../World/Prop") # definitely want to change this later
	prop.prop_clicked.connect(_on_prop_clicked)

func _on_prop_clicked(desc: String) -> void:
	var label = get_node("MarginContainer/Label")
	
	# Display prop text
	label.text = desc
	fade_node(label, Color.WHITE, 0.25)
	
	await get_tree().create_timer(3.0).timeout
	
	# Hide prop text
	fade_node(label, Color.TRANSPARENT, 1.0)

## Uses the modulate property on a CanvasItem to create a fade effect.
##
## node: node to be faded to another colour
## fade_color: final colour of the node (i.e. Color.TRANSPARENT hides a node)
func fade_node(node: CanvasItem, fade_color: Color, fade_duration: float) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(node, "modulate", fade_color, fade_duration)
