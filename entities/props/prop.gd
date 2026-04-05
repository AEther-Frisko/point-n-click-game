extends Node2D

@export var description: String = "This is an object."

signal prop_clicked(desc: String)

func _ready() -> void:
	var clickable_area = get_node("ClickableArea")
	clickable_area.clicked.connect(_on_clicked)
	
func _on_clicked() -> void:
	prop_clicked.emit(description)
