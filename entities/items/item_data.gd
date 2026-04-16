class_name ItemData extends Resource

signal texture_changed()

@export var texture: Texture2D:
	set(new_texture):
		texture = new_texture
		texture_changed.emit()
