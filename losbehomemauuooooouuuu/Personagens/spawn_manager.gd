extends Node

@export var enemy_scenes: Array[PackedScene]
@export var player_node: Node2D

@export_group("Raio de Spawn")
@export var min_spawn_radius: float = 500.0
@export var max_spawn_radius: float = 700.0

@export_group("Controle de Dificuldade")
@export var initial_spawn_amount: int = 1
@export var max_spawn_amount: int = 10
@export var initial_max_on_screen: int = 20
@export var max_total_on_screen: int = 100
@export var increase_max_on_screen_amount: int = 5
@export var min_spawn_time: float = 0.25
@export var spawn_time_multiplier: float = 0.9

@onready var spawn_timer: Timer = $SpawnTimer
@onready var difficulty_timer: Timer = $DifficultyTimer

@export var current_spawn_amount: int = 1
@export var current_max_on_screen: int = 20

func _ready():
	current_spawn_amount = initial_spawn_amount
	current_max_on_screen = initial_max_on_screen
	
	if not player_node:
		print("Erro! Nó do Jogador não definido.")
	if enemy_scenes.is_empty():
		print("Erro! Array 'Enemy Scenes' está vazio.")
			
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	if difficulty_timer:
		difficulty_timer.timeout.connect(increase_difficulty)

func _on_spawn_timer_timeout():
	
	var current_enemy_count = get_tree().get_nodes_in_group("Inimigos").size()

	if current_enemy_count >= current_max_on_screen:
		return
		
	var allowed_to_spawn = current_max_on_screen - current_enemy_count
	var num_to_spawn = min(current_spawn_amount, allowed_to_spawn)

	for i in num_to_spawn:
		var player_pos = player_node.global_position
		var random_angle = randf_range(0, TAU)
		var random_distance = randf_range(min_spawn_radius, max_spawn_radius)
		var spawn_position = player_pos + Vector2.RIGHT.rotated(random_angle) * random_distance

		var chosen_enemy_scene = enemy_scenes.pick_random()
		
		if not chosen_enemy_scene:
			continue 

		var new_enemy = chosen_enemy_scene.instantiate()
		new_enemy.global_position = spawn_position
		get_parent().add_child(new_enemy)
		
func increase_difficulty():
	print("AUMENTANDO A DIFICULDADE!")
	
	if current_spawn_amount < max_spawn_amount:
		current_spawn_amount += 1
		print("Nova quantidade de spawn por pulso: ", current_spawn_amount)
		
	if spawn_timer.wait_time > min_spawn_time:
		spawn_timer.wait_time *= spawn_time_multiplier
		spawn_timer.wait_time = max(spawn_timer.wait_time, min_spawn_time)
		print("Novo tempo de spawn: ", spawn_timer.wait_time)
		
	if current_max_on_screen < max_total_on_screen:
		current_max_on_screen += increase_max_on_screen_amount
		print("Novo limite de inimigos na tela: ", current_max_on_screen)
