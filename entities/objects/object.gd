extends Sprite2D

signal object_clicked(desc: String)
signal object_hovered(obj: String)

func _ready() -> void:
	var clickable_area = get_node("ClickableArea")
	clickable_area.clicked.connect(_on_clicked)

func _on_clicked() -> void:
	object_clicked.emit("This is an object.")

func _on_clickable_area_mouse_entered() -> void:
	object_hovered.emit("Object")
