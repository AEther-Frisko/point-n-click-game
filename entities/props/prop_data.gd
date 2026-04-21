@tool
class_name PropData extends Resource
## Unique data properties for [Prop]s.
##
## This consists of a [Texture2D], a description [String], and optional
## held [Item] information.

## Emitted when the [member texture] changes.
signal texture_changed()

## Description of the object shown when clicking on it.
@export_multiline var description := "Object description"

## Visual representation of the object.
@export var texture: Texture2D:
	set(new_texture):
		texture = new_texture
		texture_changed.emit()

## The data of the [Item] held by this object, if there is one.
@export var held_item: ItemData
## Should this [Prop] disappear when its [Item] is picked up?
@export var is_item := false
