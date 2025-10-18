class_name Player
extends CharacterBody2D

@export var speed = 400
@export var tempo = 10
@export var pontos = 0

func get_input():
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = input_direction * speed

func _physics_process(delta):
	get_input()
	move_and_slide()
	


func _on_timer_timeout() -> void:
	#get_tree().change_scene_to_file()
	pass
	
func on_enemy_death():
	pass
