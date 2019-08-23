extends Node2D

signal reach_goal

func _on_Area2D_body_entered(body):
	print("Reach goal!")
	emit_signal("reach_goal")
	pass # Replace with function body.
