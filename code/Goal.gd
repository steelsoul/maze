extends Node2D

signal reach_goal

func _on_Area2D_body_entered(_body):
	emit_signal("reach_goal")
