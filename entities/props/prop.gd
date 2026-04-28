@tool # allows sprites and collision shapes to show up in the editor
class_name Prop extends Interactable
## A type of [Interactable] for objects that appear in the game world.

## Data properties for the [Prop].
@export var prop_data: PropData

## The [Sprite2D] to visually display the [Prop].
@onready var sprite := get_node_or_null("Sprite2D")

func _ready() -> void:
	if not Engine.is_editor_hint():
		super._ready()
	
	if not prop_data:
		return
	
	if not sprite:
		sprite = Sprite2D.new()
		add_child(sprite)
	
	create_interactions()
	
	prop_data.texture_changed.connect(update_texture)
	update_texture()

func create_interactions() -> void:
	if not interaction_list.is_empty():
		return # allows overriding of default interactions
	interaction_list.append(ExamineStrategy.new())
	interaction_list[0].description = prop_data.description
	
	interaction_list.append(GetItemStrategy.new())
	interaction_list[1].item_data = prop_data.held_item

## Updates the [member sprite]'s [Texture2D] to match the current [PropData].
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
