extends Node3D

@export var bullet_scene: PackedScene
@export var shot_sound: AudioStreamMP3

@export var turret_head: Node3D
@export var shot_point_node_name: String = "ShotPoint"

@export var seconds_between_shots: float = 1
@export var inaccuracy: float = 1
@export var max_range: float = 20
@export var bullet_speed: float = 1

@export var min_shot_sound_pitch: float = 0.9
@export var max_shot_sound_pitch: float = 1.1

@export var targeting_delay_seconds: float = 2

@export_group("Debug")

@export var target: Enemy 

## Used calculating shot_deadline based on bullet_speed
@export var max_shot_duraton: float = 0.15
@export var shot_deadline: float

@export var shot_point: Node3D
@export var timer: Timer

@export var shadow_shot_point: Node3D
@export var shadow_turret_head: Node3D

func _ready() -> void:
	shot_deadline = max_shot_duraton / bullet_speed

	timer = Timer.new()
	timer.autostart = true
	timer.wait_time = seconds_between_shots + shot_deadline
	timer.timeout.connect(shoot)
	add_child(timer)
	
	shot_point = turret_head.find_child(shot_point_node_name)

	shadow_turret_head = turret_head.duplicate()
	add_child(shadow_turret_head)
	for child in shadow_turret_head.get_children(true):
		if child.name == shot_point_node_name:
			shadow_shot_point = child
		else:
			child.free()

	targeting_loop()

func shoot() -> void:
	begin_shot()

func _process(_delta: float) -> void:
	if target:
		turret_head.look_at(target.global_position, Vector3.UP)
	
func targeting_loop() -> void:
	while true:
		target_closest_enemy()
		await get_tree().create_timer(targeting_delay_seconds).timeout

func target_closest_enemy() -> void:
	var enemies = Constants.game_manager.enemies
	var space_state = get_world_3d().direct_space_state

	var enemies_within_range = []
	for enemy in enemies:
		var distance = global_position.distance_to(enemy.global_position)
		if distance <= max_range:
			var enemyBundle = {
				"enemy": enemy,
				"distance": distance
			}
			enemies_within_range.append(enemyBundle)	

	var closest: Node3D = null
	var min_distance: float = 0
	for enemyBundle in enemies_within_range:
		var enemy: Enemy = enemyBundle["enemy"]
		var distance: float = enemyBundle["distance"]

		if closest and min_distance < distance: 
			continue

		shadow_turret_head.look_at(enemy.global_position)

		var query = PhysicsRayQueryParameters3D.create(
			shadow_shot_point.global_position,
			enemy.global_position
		)
		query.exclude = [self]
		query.hit_from_inside = true

		var result = space_state.intersect_ray(query)
		if not result.is_empty() and result["collider"] == enemy:
			closest = enemy
			min_distance = distance
	
	target = closest

func begin_shot():
	if not target:
		return

	var vector_to_target = target.global_position - shot_point.global_position
	var orthogonal_unit_vector = Vector3(
		-vector_to_target.z, 
		vector_to_target.y, 
		vector_to_target.x
	).normalized()

	var offset_angle = randf_range(0, TAU)
	var offset_magnitude = randfn(0, inaccuracy)
	var offset_vector = orthogonal_unit_vector.rotated(
		vector_to_target.normalized(), 
		offset_angle
	) * offset_magnitude

	var shot_position = (
		shot_point.global_position + 
		(vector_to_target + offset_vector).normalized() * max_range
	)
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		shot_point.global_position, 
		shot_position
	)
	query.exclude = [self]
	query.hit_from_inside = true

	var result := space_state.intersect_ray(query)

	var end_position = shot_position
	if not result.is_empty():
		end_position = result["position"] as Vector3			

	var bullet = bullet_scene.instantiate() as Node3D
	add_child(bullet)
	bullet.global_position = shot_point.global_position

	if bullet.global_position.distance_to(end_position) > 0.1:
		bullet.look_at(end_position) 

	var shot_audio_player = AudioStreamPlayer3D.new()
	add_child(shot_audio_player)
	shot_audio_player.stream = shot_sound
	shot_audio_player.pitch_scale = randf_range(min_shot_sound_pitch, max_shot_sound_pitch)
	shot_audio_player.play()
	shot_audio_player.finished.connect(func(): shot_audio_player.queue_free())

	var current_shot = {
		"initial_position": shot_point.global_position,
		"end_position": end_position,
		"bullet": bullet,
		"raycast_result": result
	}

	perform_shot(current_shot)

func perform_shot(current_shot: Dictionary) -> void:
	var bullet: Node3D = current_shot["bullet"]
	
	var seconds_since_current_shot: float = 0
	var delta: float = 0
	while seconds_since_current_shot < shot_deadline:
		seconds_since_current_shot += delta

		var lerp_weight = min(seconds_since_current_shot / shot_deadline, 1)
		var bullet_position = lerp(
			current_shot["initial_position"], 
			current_shot["end_position"], 
			lerp_weight
		)

		bullet.global_position = bullet_position

		await get_tree().process_frame
		delta = get_process_delta_time()

	end_shot(current_shot)

func end_shot(current_shot: Dictionary) -> void:
	var bullet: Node3D = current_shot["bullet"]
	bullet.queue_free()

	var raycast_result: Dictionary = current_shot["raycast_result"]
	if not is_instance_valid(raycast_result["collider"]):
		return

	if raycast_result.is_empty():
		print("miss")
	else:
		var collider: Node3D = raycast_result["collider"]
		print(collider.name)
