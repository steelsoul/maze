extends Node2D

class_name Configuration

signal configuration_done

func _on_Button_pressed():
	emit_signal("configuration_done")

func get_dim():
	var lw = $Panel/VBoxContainer/HBoxContainer2/TextWithSlider
	var w = lw.get_value()
	var lh = $Panel/VBoxContainer/HBoxContainer3/TextWithSlider
	var h = lh.get_value()
	return Vector2(w, h)

func get_algorythm():
	if $Panel/VBoxContainer/HBoxContainer/CheckBoxKruscal.pressed: return "kruskal"
	else: return "prima"

func is_night_mode():
	return $Panel/VBoxContainer/HBoxContainer4/NightModeCB.pressed

func is_quest_mode():
	return $Panel/VBoxContainer/HBoxContainer5/QuestModeCB.pressed

func is_hucontrol():
	return $Panel/VBoxContainer/HBoxContainer6/HUModeCB.pressed

func has_fog():
	return $Panel/VBoxContainer/HBoxContainer4/FogCB.pressed
