class_name Player
extends CharacterBody2D

@export var speed = 400
@export var tempo = 10
@export var pontos = 0

var can_move = true	

func get_input():
	if can_move:
		var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		velocity = input_direction * speed
		print(velocity)
	else:
		velocity.x = 0
		velocity.y = 0

func _physics_process(delta):
	get_input()
	move_and_slide()

func _on_timer_timeout() -> void:
	#get_tree().change_scene_to_file()
	pass
	
func on_enemy_death():
	pass

func stop_movement_for_duration(duration:float):
	if can_move == false:
		return
	
	can_move = false
	var timer = Timer.new()
	add_child(timer)
	
	timer.one_shot = true
	timer.wait_time = duration
	timer.timeout.connect(_on_stun_timer_timeout)
	timer.start()

func _on_stun_timer_timeout():
	can_move = true
	var timer = get_node('Timer')
	if timer:
		timer.queue_free()
