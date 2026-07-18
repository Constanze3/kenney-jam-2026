class_name BuildMode
extends Node3D

@export var build_range: float = 2
@export_flags_3d_physics var raycast_collision_mask

@export_group("Debug")

@export var turret_spawner: TurretSpawner

@export var enabled: bool = false

@export var turret_to_place: Dictionary
@export var shadow: BuildShadow

@export var can_place = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_build_mode"):
		set_turret_to_place("blaster-c")

func _ready() -> void:
	turret_spawner = Constants.game_manager.turret_spawner
	exit_build_mode()

func set_turret_to_place(turret_name: String) -> void:
	if enabled:
		return

	turret_to_place = turret_spawner.get_turret_data(turret_name)
	shadow = turret_spawner.spawn_turret_build_shadow(turret_to_place)
	set_enabled(true)

func exit_build_mode() -> void:
	if shadow:
		shadow.queue_free()
	set_enabled(false)

func set_enabled(value: bool):
	set_process(value)
	set_physics_process(value)
	enabled = value
		
func _physics_process(_delta: float) -> void:
	can_place = evaluate_can_place()
	show_build_shadow()

	if Input.is_action_just_pressed("action") and can_place:
		build_turret()

func evaluate_can_place() -> bool:
	if not Constants.game_manager.can_spend_money(turret_to_place["cost"]):
		return false
	
	if shadow.is_colliding():
		can_place = false
		return false

	return true

func show_build_shadow():
	if not is_instance_valid(shadow):
		return

	var space_state = get_world_3d().direct_space_state
	var player := Constants.game_manager.player

	var camera_position = player.player_camera.global_position

	var query = PhysicsRayQueryParameters3D.create(
		camera_position,
		camera_position + (player.player_camera.global_basis * Vector3.FORWARD * build_range),
		raycast_collision_mask
	)
	query.hit_from_inside = true

	var result = space_state.intersect_ray(query)
	if result.is_empty():
		shadow.hide_shadow()
		return

	if result["normal"] != Vector3.UP:
		return

	if can_place:
		shadow.show_as_placable()
	else:
		shadow.show_as_obstructed()
	
	shadow.object.global_position = result["position"]
	shadow.object.rotation.y = player.rotation.y

func build_turret() -> void:
	var new_turret = turret_spawner.spawn_turret(turret_to_place)
	new_turret.global_position = shadow.global_position
	new_turret.global_rotation = shadow.global_rotation

	exit_build_mode()
