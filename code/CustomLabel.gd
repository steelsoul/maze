extends HBoxContainer

export (String) var text

func _ready():
	$HBoxContainer/Label.text = text

func _on_CheckBox_toggled(button_pressed):
	pass # Replace with function body.
