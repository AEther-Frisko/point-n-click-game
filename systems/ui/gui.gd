extends Control

func _ready() -> void:
	var prop = get_node("../World/Prop") # definitely want to change this later
	prop.prop_clicked.connect(_on_prop_clicked)

func _on_prop_clicked(desc: String) -> void:
	var label = get_node("MarginContainer/Label")
	label.text = desc
