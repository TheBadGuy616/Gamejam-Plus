extends Area2D

func _on_body_entered(body: CharacterBody2D):
	if body.is_in_group("Player"):
		get_tree().queue_free()
		Globais.points += 1
		print("Pontos: ", Globais.points)
