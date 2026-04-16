@tool
class_name PropData extends Resource

signal texture_changed()

@export_multiline var description: String = "Object description" ## Description of the object shown when clicking on it.
@export var texture: Texture2D: ## Visual representation of the object.
	set(new_texture):
		texture = new_texture
		texture_changed.emit()
	get():
		return texture
