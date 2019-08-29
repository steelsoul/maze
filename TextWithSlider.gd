extends Node2D

func _ready():
	$HBoxContainer/Label.text = $HBoxContainer/HSlider.value as String

func _on_HSlider_value_changed(value):
	$HBoxContainer/Label.text = value as String

func get_value():
	return $HBoxContainer/HSlider.value