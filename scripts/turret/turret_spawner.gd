class_name TurretSpawner 
extends Node3D

@export var turret_scene: PackedScene
@export var turrets_json: JSON

func get_turret_data(turret_name: String) -> Dictionary:
	for turret_data in turrets_json.data:
		if turret_data["name"] == turret_name:
			return turret_data
	
	push_error("Turret data turret with name %s not found" % turret_name)
	return {}

func _spawn_gun_model_as_child(turret_data: Dictionary, turret: Turret):
	var model_scene = load(turret_data["model_path"])
	var model = model_scene.instantiate() as Node3D
	turret.model_parent.add_child(model)

func spawn_turret(turret_data: Dictionary) -> Turret:
	var new_turret := turret_scene.instantiate() as Turret

	var d = turret_data

	new_turret.damage = d["damage"]
	new_turret.seconds_between_shots = d["seconds_between_shots"]
	new_turret.max_range = d["max_range"]
	new_turret.inaccuracy = d["inaccuracy"]
	new_turret.bullet_speed = d["bullet_speed"]
	new_turret.retargeting_delay_seconds = d["retargeting_delay_seconds"]
	new_turret.shot_sound = load(d["shot_sound_path"])

	_spawn_gun_model_as_child(turret_data, new_turret)
	
	add_child(new_turret)
	return new_turret
	
func spawn_turret_build_shadow(turret_data: Dictionary) -> BuildShadow:
	var new_turret := turret_scene.instantiate() as Turret
	var build_shadow := new_turret.build_shadow
	
	_spawn_gun_model_as_child(turret_data, new_turret)
	
	var meshes: Array[MeshInstance3D] = []
	for node in new_turret.find_children("*", "MeshInstance3D", true, false) as Array[MeshInstance3D]:
		meshes.append(node as MeshInstance3D)
	print(turret_data["max_range"])
	build_shadow.setup(meshes, turret_data["max_range"])
	
	# Remove turret script
	new_turret.set_script(null)

	add_child(new_turret)
	return build_shadow 
