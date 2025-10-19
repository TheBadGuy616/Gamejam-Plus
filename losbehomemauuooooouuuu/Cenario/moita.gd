extends Node2D

@export var slow_factor: float = 0.5
@onready var animacao = $Sprite2D
@onready var movendo: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _on_area_2d_body_entered(body) -> void:
	if body.is_in_group("Player"):
		body.apply_slow(slow_factor)
		animacao.play()
		movendo.play()

func _on_area_2d_body_exited(body) -> void:
	if body.is_in_group("Player"):
		body.remove_slow()
		animacao.stop()
		movendo.stop()
