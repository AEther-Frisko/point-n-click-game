extends Node2D

@export var prop_data: PropData

signal prop_clicked(desc: String)

func _ready() -> void:
	add_to_group("props")
	
	# set prop sprite
	var sprite := get_node("Sprite2D")
	sprite.texture = prop_data.texture
	
	# set collision shape to match sprite size
	var texture_size = sprite.texture.get_size()
	texture_size = texture_size * sprite.scale
	var collision_shape := get_node("ClickableArea/CollisionShape2D")
	collision_shape.shape.size = texture_size
	
	# connect clickable area signals
	var clickable_area = get_node("ClickableArea")
	clickable_area.clicked.connect(_on_clicked)
	clickable_area.mouse_entered.connect(_on_hover_start)
	clickable_area.mouse_exited.connect(_on_hover_end)

func _on_clicked() -> void:
	prop_clicked.emit(prop_data.description)

func _on_hover_start() -> void:
	Input.set_custom_mouse_cursor(prop_data.cursor)

func _on_hover_end() -> void:
	pass
	Input.set_custom_mouse_cursor(null)
