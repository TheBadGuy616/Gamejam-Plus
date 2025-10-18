extends Node2D

const STUN_DURATION = 1.5

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.stop_movement_for_duration(STUN_DURATION)
	queue_free()
