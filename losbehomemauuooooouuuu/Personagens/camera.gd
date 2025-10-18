extends Camera2D

var target_position

func _process(delta: float) -> void:
	global_position = global_position.lerp(target_position,delta * position_smoothing_speed)
