extends Node2D

signal configuration_done

func _on_Button_pressed():
	emit_signal("configuration_done")

func get_dim():
	var w = $LabelWidth/TextWithSlider.get_value()
	var h = $LabelHeight/TextWithSlider.get_value()
	return Vector2(w, h)

func get_algorythm():
	if $Label/CheckBoxKruscal.pressed: return "kruskal"
	else: return "prima"