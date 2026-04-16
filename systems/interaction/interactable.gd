class_name Interactable extends CanvasItem

signal clicked()
signal hover_started(node: Node)
signal hover_ended(node: Node)

@onready var clickable_area = get_node_or_null("ClickableArea")

func _ready() -> void:
	add_to_group("interactables")
	
	# create clickable area if there isn't one
	if not clickable_area:
		clickable_area = ClickableArea.new()
		add_child(clickable_area)
	
	# connect clickable area signals
	clickable_area.clicked.connect(_on_clicked)
	clickable_area.mouse_entered.connect(_on_hover_start)
	clickable_area.mouse_exited.connect(_on_hover_end)

func _on_clicked() -> void:
	clicked.emit()

func _on_hover_start() -> void:
	hover_started.emit(self)

func _on_hover_end() -> void:
	hover_ended.emit(self)
