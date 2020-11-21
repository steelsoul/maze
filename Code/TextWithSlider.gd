extends Node2D

export (int, 3, 10) var min_slider_value = 3
export (int, 10, 50) var max_slider_value = 50

func _ready():
	$HBoxContainer/HSlider.min_value = min_slider_value
	$HBoxContainer/HSlider.max_value = max_slider_value
	$HBoxContainer/DigitContainer/Label.text = $HBoxContainer/HSlider.value as String

func _on_HSlider_value_changed(value):
	$HBoxContainer/DigitContainer/Label.text = value as String

func get_value():
	return $HBoxContainer/HSlider.value
