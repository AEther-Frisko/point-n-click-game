class_name Door extends Interactable

## Name of the room [PackedScene] to load when this [Door] is used.[br]
## For example:[br]
## "[b]room[/b]" loads "res://entities/rooms/[b]room[/b].tscn".
@export var destination : String

func _ready() -> void:
	super._ready()
	add_to_group("doors")

func _on_clicked() -> void:
	clicked.emit(destination)
