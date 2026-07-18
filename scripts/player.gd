class_name Player
extends CharacterBody3D

@export var player_camera: Camera3D

@export var sensitivity: float = 1.0
@export var sensitivity_multiplier: float = 0.005

@export var movement_speed: float = 10.0
@export var jump_force: float = 10.0

@export var yaw: float
@export var pitch: float

@export var direction: Vector2 = Vector2.ZERO

@export var hotbar : ItemList
@export var turret_data : JSON

var selected : int = -1

func _ready() -> void:
	#Set up the hotbar prices when the game is getting started.
	for i in 7:
		hotbar.set_item_text(i, str(turret_data.data[i]["cost"]) + "$")
	

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
	
	#Hotbar selection
	if Input.is_action_just_pressed("1"):
		if selected == 0:
			hotbar.deselect_all()
			selected = -1
		else:
			selected = 0
			hotbar.select(0)
	if Input.is_action_just_pressed("2"):
		if selected == 1:
			hotbar.deselect(1)
			selected = -1
		else:
			selected = 1
			hotbar.select(1)
	if Input.is_action_just_pressed("3"):
		if selected == 2:
			hotbar.deselect(2)
			selected = -1
		else: 
			selected = 2
			hotbar.select(2)	
	if Input.is_action_just_pressed("4"):
		if selected == 3:
			hotbar.deselect(3)
			selected = -1
		else:
			selected = 3
			hotbar.select(3)
	if Input.is_action_just_pressed("5"):
		if selected == 4:
			hotbar.deselect(4)
			selected = -1
		else:
			selected = 4
			hotbar.select(4)
	if Input.is_action_just_pressed("6"):
		if selected == 5:
			hotbar.deselect(5)
			selected = -1
		else:
			selected = 5
			hotbar.select(5)
	if Input.is_action_just_pressed("7"):
		if selected == 6:
			hotbar.deselect(6)
			selected = -1
		else:
			selected = 6
			hotbar.select(6)
	
	move_and_slide()	
