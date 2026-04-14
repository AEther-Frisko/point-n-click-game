class_name Door extends Interactable

@export var destination : String

func _ready() -> void:
	super._ready()
	add_to_group("doors")

func _on_clicked() -> void:
	clicked.emit(destination)
