class_name GameManager
extends Node

@export var tower : Node3D
@export var enemy_spawner : EnemySpawner
@export var player: Player
@export var turret_spawner: TurretSpawner

@export_category("Tower Data")
@export var max_tower_health : float
@export var tower_health : float

@export_category("Enemy/Wave")
@export var enemies: Array[Enemy] = []
@export var wave_no : int = -1
@export var current_enemy_count : int
@export var wave_enemy_count : int
@export var wait_timer : float
@export var wave_data : JSON
@export var bank : int

var cake_protected: bool = false

var before_wave: bool = true
var wave_ended: bool = false

var before_first_wave_timer: SceneTreeTimer

func _enter_tree() -> void:
	Constants.game_manager = self
	
func _process(_delta: float) -> void:
	if tower_health <= 0:
		game_over()
	
	if not before_wave and current_enemy_count == 0 and !wave_ended:
		end_wave()
		wave_ended = true

func _ready() -> void:
	tower_health = max_tower_health	
	start_wave()

func can_spend_money(amound: int) -> bool:
	return amound <= bank

## Returns false if there isn't enough money in the bank, true on success.
func try_spend_money(amount: int) -> bool:
	if not can_spend_money(amount):
		return false

	bank -= amount
	return true

func start_wave() -> void:
	before_wave = true
	before_first_wave_timer = get_tree().create_timer(15.0)
	await before_first_wave_timer.timeout
	before_wave = false

	wave_no += 1

	if wave_no >= wave_data.data.size():
		cake_protected = true
		print("All waves finished!")
		return
	
	print("New wave started!")
	
	var current_wave = wave_data.data[wave_no]
	var enemy_counts = current_wave["enemy_counts"]
	
	wave_enemy_count = 0
	
	for enemy_name in enemy_counts:
		var enemy_count = int(enemy_counts[enemy_name])
		
		wave_enemy_count += enemy_count
		enemy_spawner.spawn_enemies(enemy_name, enemy_count)
	
	current_enemy_count = wave_enemy_count
	wave_ended = false
	
	return


func end_wave() -> void:
	print("Wave ended!")
	await get_tree().create_timer(wait_timer).timeout
	start_wave()
	return


func damage_tower(damage_amount : int) -> void:
	tower_health = tower_health - damage_amount

func game_over() -> void:
	return
