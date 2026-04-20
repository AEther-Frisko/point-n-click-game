@tool
class_name PropData extends Resource
## Unique data properties for [Prop]s.
##
## Right now this is a [Texture2D] and a description [String].

## Emitted when the [member texture] changes.
signal texture_changed()

## Description of the object shown when clicking on it.
@export_multiline var description: String = "Object description"

## Visual representation of the object.
@export var texture: Texture2D:
	set(new_texture):
		texture = new_texture
		texture_changed.emit()

## The data of the [Item] held by this object, if there is one.
@export var held_item: ItemData
