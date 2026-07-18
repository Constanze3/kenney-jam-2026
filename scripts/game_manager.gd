class_name GameManager
extends Node

@export var tower : Node3D
@export var enemy_spawner : EnemySpawner
@export_category("Tower Data")
@export var max_tower_health : float
@export var tower_health : float
@export_category("Enemy/Wave")
@export var wave_no : int
@export var current_enemy_count : int
@export var wave_enemy_count : int
@export var wait_timer : float
@export var wave_data: JSON


var wave_ended: bool = false

func _enter_tree() -> void:
	Constants.game_manager = self
	

func _process(delta: float) -> void:
	if tower_health <= 0:
		game_over()
	if current_enemy_count == 0 and !wave_ended:
		end_wave()
		wave_ended = true
	

func _ready() -> void:
	tower_health = max_tower_health
	wave_no = 0
	start_wave()

func start_wave() -> void:
	print("New wave started!")
	wave_no += 1
	
	#wave_enemy_count = wave_array[wave_no]
	#current_enemy_count = wave_enemy_count
	
	#enemy_spawner.spawn_enemies(wave_array[wave_no])
	#wave_ended = false
	return

func end_wave() -> void:
	print("Wave ended!")
	await get_tree().create_timer(wait_timer).timeout
	start_wave()
	return

func damage_tower (damage_amount : int) -> void:
	tower_health = tower_health - damage_amount

func game_over() -> void:
	return
