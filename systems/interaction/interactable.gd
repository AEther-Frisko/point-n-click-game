class_name Interactable extends Node2D

signal clicked()
signal hover_started(node: Node)
signal hover_ended(node: Node)

func _ready() -> void:
	add_to_group("interactables")
	
	# connect signals to attached clickable area, if there is one
	var clickable_area = get_node_or_null("ClickableArea")
	if clickable_area != null:
		clickable_area.clicked.connect(_on_clicked)
		clickable_area.mouse_entered.connect(_on_hover_start)
		clickable_area.mouse_exited.connect(_on_hover_end)

func _on_clicked() -> void:
	clicked.emit()

func _on_hover_start() -> void:
	hover_started.emit(self)

func _on_hover_end() -> void:
	hover_ended.emit(self)
