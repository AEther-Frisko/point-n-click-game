@tool # allows sprites and collision shapes to show up in the editor
extends Node2D

@export var prop_data: PropData

@onready var sprite := get_node("Sprite2D")

signal prop_clicked(desc: String)

func update_texture(new_texture: Texture2D) -> void:
	# set prop sprite
	sprite.texture = new_texture
		
	# set collision shape to match sprite size
	var texture_size = sprite.texture.get_size()
	texture_size = texture_size * sprite.scale
	var collision_shape := get_node("ClickableArea/CollisionShape2D")
	collision_shape.shape.size = texture_size

func _ready() -> void:
	add_to_group("props")
	
	if prop_data == null:
		return
	update_texture(prop_data.texture)
	
	# connect clickable area signals
	if not Engine.is_editor_hint():
		var clickable_area = get_node("ClickableArea")
		clickable_area.clicked.connect(_on_clicked)
		clickable_area.mouse_entered.connect(_on_hover_start)
		clickable_area.mouse_exited.connect(_on_hover_end)

func _process(_delta: float) -> void:
	if prop_data == null:
		sprite.texture = null
	elif prop_data.texture != sprite.texture:
		update_texture(prop_data.texture)

func _on_clicked() -> void:
	prop_clicked.emit(prop_data.description)

func _on_hover_start() -> void:
	Input.set_custom_mouse_cursor(prop_data.cursor)

func _on_hover_end() -> void:
	Input.set_custom_mouse_cursor(null)
