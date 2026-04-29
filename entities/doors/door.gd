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
	
	if not lock_data:
		lock_data = LockData.new()
		lock_data.is_locked = false
	
	create_interactions()

func create_interactions() -> void:
	if interaction_list.is_empty():
		interaction_list.append(LoadRoomStrategy.new())
		
		interaction_list.append(ExamineStrategy.new())
		interaction_list.back().description = "It's locked."
		
		interaction_list.append(UseItemStrategy.new())
		interaction_list.back().success = UnlockDoorStrategy.new()
