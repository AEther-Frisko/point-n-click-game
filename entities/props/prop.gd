extends Node2D

@export var propData: PropData

signal prop_clicked(desc: String)

func _ready() -> void:
	# set prop sprite
	var sprite := get_node("Sprite2D")
	sprite.texture = propData.texture
	
	# set collision shape to match sprite size
	var texture_size = sprite.texture.get_size()
	texture_size = texture_size * sprite.scale
	var collision_shape := get_node("ClickableArea/CollisionShape2D")
	collision_shape.shape.size = texture_size
	
	var clickable_area = get_node("ClickableArea")
	clickable_area.clicked.connect(_on_clicked)

func _on_clicked() -> void:
	prop_clicked.emit(propData.description)
