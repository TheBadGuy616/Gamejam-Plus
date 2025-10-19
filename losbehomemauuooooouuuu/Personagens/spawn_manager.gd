extends Node

@export var enemy_scenes : Array[PackedScene]
@export var player_node : Node2D
@export var min_spawn_range = 800
@export var max_spawn_range = 1000

@onready var spawn_timer: Timer = $SpawnTimer

func _ready() -> void:
	if not player_node:
		print("Erro! Nó do Jogador não foi definido no SpawnManager.")
		return
	if enemy_scenes.is_empty():
		print("Erro! O array 'Enemy Scenes' está vazio no SpawnManager.")
	for scene in enemy_scenes:
		if not scene:
			print("Aviso! Há um espaço vazio no array 'Enemy Scenes' do SpawnManager.")
		return
		
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func _on_spawn_timer_timeout():
	print(1)
	var player_pos = player_node.global_position
	var random_angle = randf_range(0, TAU)
	var random_distance = randf_range(min_spawn_range,max_spawn_range)
	var spawn_position = player_pos + Vector2.RIGHT.rotated(random_angle) * random_distance
	var chosen_enemy_scene = enemy_scenes.pick_random()
	if not chosen_enemy_scene:
		print("Aviso: Tentou instanciar um inimigo nulo (vazio) do array.")
	var new_enemy = chosen_enemy_scene.instantiate()
	new_enemy.global_position = spawn_position
	get_parent().add_child(new_enemy)
	
	
