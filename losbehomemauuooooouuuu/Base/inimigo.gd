extends CharacterBody2D

@export var velocidade: float = 300
@export var wander_radius: int = 450 

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var wait_timer: Timer = $Timer 

var start_position : Vector2
var protagonista_ref = null


func _ready() -> void:
	start_position = global_position
	nav_agent.target_reached.connect(_on_target_reached)
	wait_timer.timeout.connect(pick_new_random_target)
	wait_timer.wait_time = randf_range(2.0,5.0)
	pick_new_random_target()
	
func _physics_process(delta):
	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
	
	var next_path_pos = nav_agent.get_next_path_position()
	var direction = global_position.direction_to(next_path_pos)
	velocity = direction * velocidade
	
	move_and_slide()

func pick_new_random_target():
	var random_angle = randf_range(0, TAU)
	var random_distance = randf_range(0, wander_radius)
	var target_point = start_position + Vector2.RIGHT.rotated(random_angle) * random_distance
	var safe_point = NavigationServer2D.map_get_closest_point(nav_agent.get_navigation_map(),target_point)
	nav_agent.set_target_position(safe_point)

func _on_target_reached():
	velocity = Vector2.ZERO
	wait_timer.wait_time = randf_range(2.0, 5.0)
	wait_timer.start()


func _ao_contato_com_protagonista(protagonista):
	#Comportamento padrão:
	print("Inimigo base tocou no protagonista. Nada acontece.")
	pass
