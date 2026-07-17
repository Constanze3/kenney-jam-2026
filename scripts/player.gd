extends CharacterBody3D

@export var player_camera: Camera3D

@export var sensitivity: float = 1.0
@export var sensitivity_multiplier: float = 0.005

@export var movement_speed: float = 10.0
@export var jump_force: float = 10.0

@export var yaw: float
@export var pitch: float

@export var direction: Vector2 = Vector2.ZERO
@export var should_jump: bool = false

func get_sensitivity() -> float:
	return sensitivity * sensitivity_multiplier

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		yaw -= event.screen_relative.x * get_sensitivity() 
		pitch -= event.screen_relative.y * get_sensitivity() 
		pitch = clamp(pitch, -PI / 2, PI / 2)

	if event.is_action_pressed("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if event is InputEventMouseButton and event.is_pressed():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_delta: float) -> void:
		direction = Input.get_vector("left", "right", "forward", "backward")
		
		rotation.y = yaw
		player_camera.rotation.x = pitch

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity += Vector3.UP * jump_force

	if not is_on_floor():
		velocity += get_gravity() * delta
		
	var movement = transform.basis * Vector3(direction.x, 0, direction.y) * movement_speed
	velocity.x = movement.x
	velocity.z = movement.z

	move_and_slide()	

