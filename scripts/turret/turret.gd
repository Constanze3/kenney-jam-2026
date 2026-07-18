extends Node3D

@export var bullet_scene: PackedScene
@export var shot_point: Node3D

@export var seconds_between_shots: float = 1
@export var inaccuracy: float = 1
@export var max_range: float = 20
@export var bullet_speed: float = 5

@export var max_shot_duraton: float = 0.2

@export_category("debug")
@export var target: Node3D
@export var should_shoot: bool = false

@export var something: PackedScene

var timer: Timer

var has_active_shot: bool = false
var current_shot: Dictionary

var current_shot_deadline: float = 0
var seconds_since_current_shot: float = 0

func _ready() -> void:
	timer = Timer.new()
	timer.autostart = true
	timer.wait_time = seconds_between_shots 
	timer.timeout.connect(shoot)
	add_child(timer)

func shoot() -> void:
	should_shoot = true

func _process(delta: float) -> void:
	look_at(target.position, Vector3.UP)

	if has_active_shot:
		perform_shot(delta)

func perform_shot(delta: float) -> void:
	var shot_deadline = max_shot_duraton / bullet_speed
	seconds_since_current_shot += delta

	var lerp_weight = min(seconds_since_current_shot / shot_deadline, 1)
	var bullet_position = lerp(
		current_shot["initial_position"], 
		current_shot["end_position"], 
		lerp_weight
	)

	var bullet = current_shot["bullet"] as Node3D
	bullet.global_position = bullet_position

	if shot_deadline < seconds_since_current_shot:
		has_active_shot = false
		bullet.queue_free()
		end_shot(current_shot["raycast_result"])

func end_shot(raycast_result: Dictionary):
	if raycast_result.is_empty():
		print("miss")
	else:
		var collider = raycast_result["collider"] as Node3D
		print(collider.name)

func _physics_process(_delta: float) -> void:
	if should_shoot:
		should_shoot = false
		begin_shot()

func begin_shot():
	var vector_to_target = target.global_position - global_position 
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

	var shot_position = position + (vector_to_target + offset_vector).normalized() * max_range
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(position, shot_position)
	query.exclude = [self]

	var result := space_state.intersect_ray(query)

	var end_position = shot_position
	if not result.is_empty():
		end_position = result["position"] as Vector3			

	var bullet = bullet_scene.instantiate() as Node3D
	add_child(bullet)
	bullet.global_position = shot_point.global_position

	has_active_shot = true
	current_shot = {
		"initial_position": shot_point.global_position,
		"end_position": end_position,
		"bullet": bullet,
		"raycast_result": result
	}
	seconds_since_current_shot = 0
