extends Node3D

@export var seconds_between_shots: float = 1
@export var inaccuracy: float = 1

@export var target: Node3D
@export var should_shoot: bool = false

@export var something: PackedScene

var timer: Timer

func _ready() -> void:
	timer = Timer.new()
	timer.autostart = true
	timer.wait_time = seconds_between_shots 
	timer.timeout.connect(shoot)
	add_child(timer)

func _process(_delta: float) -> void:
	look_at(target.position, Vector3.UP)

func _physics_process(_delta: float) -> void:
	if should_shoot:
		should_shoot = false

		var vector_to_target = target.global_position - global_position 
		var orthogonal_unit_vector = Vector3(
			-vector_to_target.z, 
			vector_to_target.y, 
			vector_to_target.x
		).normalized()

		var offset_angle = randf_range(0, TAU)
		var offset_magnitude = randfn(0, inaccuracy)
		var offset_vector = orthogonal_unit_vector.rotated(vector_to_target.normalized(), offset_angle) * offset_magnitude

		var shot_vector = vector_to_target + offset_vector

		var indicator = something.instantiate() as Node3D
		add_child(indicator)
		indicator.global_position = global_position + shot_vector


func shoot() -> void:
	should_shoot = true
