class_name EnemySpawner
extends Node

@export var enemy_scene : PackedScene
@export var spawn_radius : float
@export var enemy_data : JSON

var angle : float


func spawn_enemies(enemy_name : String, count : int) -> void:
	var enemy_array = enemy_data.data

	for i in count:
		var new_enemy := enemy_scene.instantiate() as Enemy
		add_child(new_enemy)
		
		angle = randf() * TAU
		
		new_enemy.global_position = Vector3(
			cos(angle) * spawn_radius,
			10.0,
			sin(angle) * spawn_radius
		)
		
		for data in enemy_array:
			if data["name"] == enemy_name:
				new_enemy.set_enemy_data(data)
				break
