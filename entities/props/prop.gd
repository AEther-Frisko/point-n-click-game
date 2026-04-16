@tool # allows sprites and collision shapes to show up in the editor
class_name Prop extends Interactable

@export var prop_data: PropData

@onready var sprite := get_node_or_null("Sprite2D")

func _ready() -> void:
	if not Engine.is_editor_hint():
		super._ready()
	add_to_group("props")
	
	if not prop_data:
		return
	
	if not sprite:
		sprite = Sprite2D.new()
		add_child(sprite)
	
	prop_data.texture_changed.connect(update_texture)
	update_texture()

func update_texture(new_texture = prop_data.texture) -> void:
	# set prop sprite
	sprite.texture = new_texture
	if not new_texture:
		return
	
	# set collision shape to match sprite size
	var texture_size = sprite.texture.get_size()
	texture_size = texture_size * sprite.scale
	var collision_shape := get_node("ClickableArea/CollisionShape2D")
	collision_shape.shape.size = texture_size

func _on_clicked() -> void:
	clicked.emit(prop_data.description)
