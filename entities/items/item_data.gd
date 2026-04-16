class_name ItemData extends Resource

## Emitted when the [member texture] changes.
signal texture_changed()

## Visual representation of the [Item] to be drawn to the screen.
@export var texture: Texture2D:
	set(new_texture):
		texture = new_texture
		texture_changed.emit()
