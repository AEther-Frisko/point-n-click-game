extends Label

# Definitely will not be staying this way, just testing
func _ready() -> void:
	var object = get_node("../../../World/Object")
	object.object_clicked.connect(_on_object_clicked)
	object.object_hovered.connect(_on_object_hovered)

func _on_object_clicked(desc: String) -> void:
	text = desc

func _on_object_hovered(obj: String) -> void:
	text = obj
