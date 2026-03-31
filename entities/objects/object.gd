extends Sprite2D

func _ready() -> void:
	var clickable_area = get_node("ClickableArea")
	clickable_area.clicked.connect(_on_clicked)

func _on_clicked() -> void:
	print("Clicked!")
