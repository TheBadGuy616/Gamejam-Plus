extends Node2D

@export var slow_factor: float = 0.5

func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.apply_slow(slow_factor)

func _on_body_exited(body):
	if body.is_in_group("Player"):
		body.remove_slow()
