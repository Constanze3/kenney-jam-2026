class_name BuildMode
extends Node3D

@export var build_range: float = 2
@export_flags_3d_physics var raycast_collision_mask
@export_flags_3d_physics var can_place_on_mask 

@export_group("Debug")

@export var turret_spawner: TurretSpawner

@export var enabled: bool = false

@export var turret_to_place: Dictionary
@export var shadow: BuildShadow

@export var can_place = false
@export var lock_placed_object = false

func _ready() -> void:
	turret_spawner = Constants.game_manager.turret_spawner
	exit_build_mode()

func set_turret_to_place(turret_name: String) -> void:
	if shadow:
		shadow.queue_free()
	
	turret_to_place = turret_spawner.get_turret_data(turret_name)

	shadow = turret_spawner.spawn_turret_build_shadow(turret_to_place)
	update_build_shadow()

	set_enabled(true)

func exit_build_mode() -> void:
	if shadow:
		shadow.queue_free()

	Constants.game_manager.player.max_range_indicator.hide()
	set_enabled(false)

func set_enabled(value: bool):
	set_process(value)
	set_physics_process(value)
	lock_placed_object = false

	enabled = value
		
func _physics_process(_delta: float) -> void:
	if enabled and Input.is_action_pressed("secondary_action"):
		lock_placed_object = true 
	else:
		lock_placed_object = false
	
	if !lock_placed_object:
		update_build_shadow()	

	if Input.is_action_just_pressed("action") and can_place:
		build_turret()

func evaluate_can_place(raycast_result: Dictionary) -> bool:
	if not Constants.game_manager.can_spend_money(turret_to_place["cost"]):
		return false
	
	if shadow.is_colliding():
		can_place = false
		return false

	if raycast_result.is_empty():
		return false

	if raycast_result["normal"] != Vector3.UP:
		return false

	var collider: CollisionObject3D = raycast_result["collider"]
	if collider.collision_layer & can_place_on_mask == 0:
		return false

	return true

func should_show_shadow(raycast_result: Dictionary) -> bool:
	if raycast_result.is_empty():
		return false

	if raycast_result["normal"] != Vector3.UP:
		return false

	return true

func update_build_shadow():
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

	can_place = evaluate_can_place(result)
	var show_shadow = should_show_shadow(result)

	if can_place:
		shadow.show_as_placable()
	elif show_shadow:
		shadow.show_as_obstructed()
	else:
		shadow.hide_shadow()
	
	if not result.is_empty():
		shadow.object.global_position = result["position"]

	shadow.object.rotation.y = player.rotation.y - PI / 2

func build_turret() -> void:
	if Constants.game_manager.try_spend_money(turret_to_place["cost"]):
		var new_turret = turret_spawner.spawn_turret(turret_to_place)
		new_turret.global_position = shadow.global_position
		new_turret.global_rotation = shadow.global_rotation
		update_build_shadow()
	else:
		push_error("There should be enough money in the bank to build a turret here")
