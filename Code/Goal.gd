extends Node2D

signal reach_goal

func set_collision_enabled():
	$Area2D/CollisionShape2D.disabled = false

func _on_Area2D_body_entered(_body):
	#print("Reach goal!")
	emit_signal("reach_goal")
