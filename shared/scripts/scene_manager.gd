class_name SceneManager extends Node2D

## Currently loaded room scene.
var current_room : Node2D

## Emitted once a new room has been loaded into the scene.
signal room_loaded()

func _ready() -> void:
	load_room("room")

## Unloads the [member current_room] from the [SceneTree].
func unload_room() -> void:
	if is_instance_valid(current_room):
		current_room.queue_free()
	current_room = null

## Loads a new room [PackedScene] according to the specified destination [String].
func load_room(destination: String) -> void:
	unload_room()
	var room_path := "res://entities/rooms/%s.tscn" % destination
	var new_room = load(room_path)
	if new_room:
		current_room = new_room.instantiate()
		current_room.ready.connect(_on_room_loaded)
		add_child(current_room)

func _on_room_loaded() -> void:
	room_loaded.emit()
