class_name ItemData extends Resource
## Unique data properties for [Item]s.
##
## Right now this is just a [Texture2D], which determines
## how the item will appear on the screen.

## Emitted when the [member texture] changes.
signal texture_changed()

## Visual representation of the [Item] to be drawn to the screen.
@export var texture: Texture2D:
	set(new_texture):
		texture = new_texture
		texture_changed.emit()
