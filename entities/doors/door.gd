class_name Door extends Interactable
## A type of [Interactable] meant for connecting multiple rooms together.
##
## Holds a [member destination] [String], which determines which [PackedScene]
## to load when it is used.

## Name of the room [PackedScene] to load when this [Door] is used.[br]
## For example:[br]
## "[b]room[/b]" loads "res://entities/rooms/[b]room[/b].tscn".
@export var destination : String

func _ready() -> void:
	super._ready()
	current_interaction = LoadRoomStrategy.new()
	current_interaction.destination = destination
