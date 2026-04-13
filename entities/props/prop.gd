@tool # allows sprites and collision shapes to show up in the editor
class_name Prop extends Interactable

@export var prop_data: PropData

@onready var sprite := get_node("Sprite2D")

func update_texture(new_texture: Texture2D) -> void:
	# set prop sprite
	sprite.texture = new_texture
		
	# set collision shape to match sprite size
	var texture_size = sprite.texture.get_size()
	texture_size = texture_size * sprite.scale
	var collision_shape := get_node("ClickableArea/CollisionShape2D")
	collision_shape.shape.size = texture_size

func _ready() -> void:
	if not Engine.is_editor_hint():
		super._ready()
	add_to_group("props")
	
	if prop_data == null:
		return
	update_texture(prop_data.texture)

func _process(_delta: float) -> void:
	if prop_data == null:
		sprite.texture = null
	elif prop_data.texture != sprite.texture:
		update_texture(prop_data.texture)

func _on_clicked() -> void:
	clicked.emit(prop_data.description)
