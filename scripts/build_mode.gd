class_name BuildMode
extends Node3D

@export var build_range: float = 2
@export var build_height: float = 1.5

@export_flags_3d_physics var raycast_collision_mask
@export_flags_3d_physics var can_place_on_mask 

@export_group("Debug")

@export var turret_spawner: TurretSpawner

@export var enabled: bool = false

@export var turret_to_place: Dictionary
@export var shadow: BuildShadow

@export var can_place = true
@export var show_shadow = true

@export var lock_placed_object = false
@export var locked_once = false

var tm = false

var player: Player

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		tm = !tm
		print(tm)

func _ready() -> void:
	player = Constants.game_manager.player
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

	player.max_range_indicator.hide()
	set_enabled(false)

func set_enabled(value: bool):
	set_process(value)
	set_physics_process(value)
	lock_placed_object = false

	enabled = value
		
var locked_once_timer: Timer = null
func _physics_process(_delta: float) -> void:
	if enabled and Input.is_action_pressed("secondary_action"):
		lock_placed_object = true 

		if not locked_once and not is_instance_valid(locked_once_timer):
			locked_once_timer = Timer.new()
			add_child(locked_once_timer)

			locked_once_timer.one_shot = true
			locked_once_timer.wait_time = 0.5
			locked_once_timer.timeout.connect(func(): 
				locked_once = true
			)
			locked_once_timer.start()
	else:
		if locked_once_timer:
			locked_once_timer.free()
		lock_placed_object = false
	
	if !lock_placed_object:
		update_build_shadow()	

	if Input.is_action_just_pressed("action") and can_place:
		build_turret()

func evaluate_placement_details(raycast_result: Dictionary) -> void:
	can_place = true
	show_shadow = true

	if not Constants.game_manager.can_spend_money(turret_to_place["cost"]):
		can_place = false 
		return
	
	if shadow.is_colliding():
		can_place = false
		return

	if raycast_result.is_empty():
		can_place = false
		show_shadow = false
		return

	if (raycast_result["position"] as Vector3).distance_to(
		player.player_camera.global_position
	) > build_range:
		can_place = false
		show_shadow = false
		return

	if Vector3.UP.dot(raycast_result["normal"]) < 0.7:
		can_place = false
		show_shadow = false
		return

	var collider: CollisionObject3D = raycast_result["collider"]
	if collider.collision_layer & can_place_on_mask == 0:
		can_place = false
		return

func update_build_shadow():
	if not is_instance_valid(shadow):
		return

	var space_state = get_world_3d().direct_space_state
	
	var camera := player.player_camera
	var camera_forward := -camera.global_basis.z.normalized()
	
	var query_1 = PhysicsRayQueryParameters3D.create(
		camera.global_position,
		camera.global_position + camera_forward * build_range
	)
	query_1.exclude = [player]

	var result_1 := space_state.intersect_ray(query_1)

	# hard coded based for now
	var camera_height = 1 + camera.position.y
	
	var the_position = null
	if not result_1.is_empty():
		the_position = result_1["position"]
	else:
		the_position = camera.global_position + camera_forward * (camera_height / abs(camera_forward.dot(Vector3.DOWN)))

	var result_vector_1 = (the_position - camera.global_position) as Vector3
	var length = result_vector_1.length() / camera_height * (camera_height - build_height)

	var ground_query_position = camera.global_position + camera_forward * length

	var query = PhysicsRayQueryParameters3D.create(
		ground_query_position,
		ground_query_position + Vector3.DOWN * (build_height + 0.1),
		raycast_collision_mask
	)
	query.hit_from_inside = true

	var result = space_state.intersect_ray(query)
	evaluate_placement_details(result)

	if can_place:
		shadow.show_as_placable()
	elif show_shadow:
		shadow.show_as_obstructed()
	else:
		shadow.hide_shadow()

	if not result.is_empty():
		shadow.object.global_position = result["position"]
		
		var original_scale = shadow.object.global_basis.get_scale()
		var player_forward = -player.global_basis.z.normalized()
		var new_basis = Basis()
		new_basis.y = (result["normal"] as Vector3).normalized() * original_scale.y
		new_basis.z  = -(player_forward - (new_basis.y * new_basis.y.dot(player_forward))).normalized() * original_scale.z
		new_basis.x = new_basis.y.cross(new_basis.z).normalized() * original_scale.x

		shadow.object.global_basis = new_basis

func build_turret() -> void:
	if Constants.game_manager.try_spend_money(turret_to_place["cost"]):
		var new_turret = turret_spawner.spawn_turret(turret_to_place)
		new_turret.global_position = shadow.global_position
		new_turret.global_rotation = shadow.global_rotation
		update_build_shadow()
	else:
		push_error("There should be enough money in the bank to build a turret here")
