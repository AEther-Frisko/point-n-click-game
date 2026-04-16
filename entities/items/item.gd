@tool
class_name Item extends Interactable

@onready var texture_rect := get_node_or_null("TextureRect")
@onready var area_container: Control = $AreaContainer

@export var item_data: ItemData

func _ready() -> void:
	super._ready()
	add_to_group("items")
	
	if not texture_rect:
		texture_rect = TextureRect.new()
		add_child(texture_rect)
	if not item_data:
		item_data = ItemData.new()
	item_data.texture_changed.connect(update_texture)
	update_texture()
	
	# doesn't need it?
	clickable_area.queue_free()
	
	area_container.mouse_entered.connect(_on_hover_start)
	area_container.mouse_exited.connect(_on_hover_end)
	area_container.gui_input.connect(_on_input)

func update_texture(new_texture = item_data.texture) -> void:
	texture_rect.texture = new_texture

func _on_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		get_viewport().set_input_as_handled()
		clicked.emit("You are clicking an item")

func _on_hover_start() -> void:
	hover_started.emit(self)

func _on_hover_end() -> void:
	hover_ended.emit(self)
