class_name  EnemySpawner
extends Node
@export var enemy_scene : PackedScene
@export var spawn_radius : float
@export var enemy_data : JSON
var angle : float

func spawn_enemies(count : int) -> void:
	for i in count:
		var new_enemy := enemy_scene.instantiate() as Node3D
		add_child(new_enemy) 
		angle = randf() * TAU
		new_enemy.global_position =  (Vector3 (
				cos(angle) * spawn_radius, 
				10.0, 
				sin(angle) * spawn_radius 
				))
 
