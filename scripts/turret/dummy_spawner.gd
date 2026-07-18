class_name DummySpawner
extends Node3D

@export var turret_scene : PackedScene
@export var turret_data : JSON
@export var spawn_radius : float = 8.0
@export var amount_to_spawn : int = 3


func _ready() -> void:
	spawn_dummy_turrets()


func spawn_dummy_turrets() -> void:
	var turret_array = turret_data.data
	
	for i in amount_to_spawn:
		var data = turret_array[i % turret_array.size()]
		spawn_turret(data, i)


func spawn_turret(data : Dictionary, index : int) -> void:
	var new_turret := turret_scene.instantiate() as Turret
	
	set_turret_data(new_turret, data)
	add_child(new_turret)
	
	var angle = TAU / amount_to_spawn * index
	
	new_turret.global_position = global_position + Vector3(
		cos(angle) * spawn_radius,
		0,
		sin(angle) * spawn_radius
	)


func set_turret_data(turret : Turret, data : Dictionary) -> void:
	turret.damage = data["damage"]
	turret.seconds_between_shots = data["fire_rate"]
	turret.max_range = data["max_range"]
	turret.inaccuracy = data["inaccuracy"]
	turret.bullet_speed = data["bullet_speed"]
	turret.targeting_delay_seconds = data["re_targeting_delay"]
	turret.shot_sound = load(data["shot_sound_path"])
	
	var model_scene = load(data["model_path"])

	if model_scene and turret.model_parent:
		var model = model_scene.instantiate()
		turret.model_parent.add_child(model)
