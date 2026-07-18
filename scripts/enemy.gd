class_name Enemy
extends CharacterBody3D

@export var face_area : Area3D
@export var model_parent : Node3D

@export_category("Movement")
@export var jump_force : float
@export var climbing_velocity : float
@export var speed = 5.0

@export_category("Enemy Data")
@export var health : float
@export var damage : int
@export var money : int

@export_group("Debug")
@export var climbing : bool
@export var should_jump : bool

func _enter_tree() -> void:
	Constants.game_manager.enemies.append(self)

func _ready() -> void:
	face_area.body_entered.connect(on_body_entered)
	face_area.body_exited.connect(on_body_exited)

#Sets the values from enemies.json
func set_enemy_data(data : Dictionary) -> void:
	health = data["health"]
	damage = data["damage"]
	speed = data["walk_speed"]
	climbing_velocity = data["climb_speed"]
	jump_force = data["jump_height"]
	money = data["money"]
	scale = Vector3.ONE * float(data["scale"])

	var model_scene = load(data["path"])

	if model_scene and model_parent:
		var model = model_scene.instantiate()
		model_parent.add_child(model)


func _physics_process(delta: float) -> void:
	var target := Vector3(0,global_position.y,0)
	if global_position.distance_to(target) > 0.1:
		look_at(target) 

	# Add the gravity.	
	if not is_on_floor() and not climbing:
		velocity += get_gravity() * delta
	
	if should_jump and is_on_floor() and not climbing:
		velocity += Vector3.UP * jump_force
		should_jump = false 
	
	if climbing:
		climb()
	
	var direction := (Vector3(0,30,0) - global_position).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()


#Function called when climbing surfaces
func climb() -> void:
	velocity.y = climbing_velocity

#Used to keep track of the amount of current enemies left in GameManager
func _exit_tree() -> void:
	var index = Constants.game_manager.enemies.find(self)
	Constants.game_manager.enemies.remove_at(index)

	Constants.game_manager.current_enemy_count -= 1
	Constants.game_manager.bank += money

func on_body_entered(body: Node3D) -> void:
	if body is Enemy and body.name != name:
		should_jump = true
	if body == Constants.game_manager.tower:
		climbing = true	
		return

func on_body_exited(body: Node3D) -> void:
	if body == Constants.game_manager.tower:
		climbing = false
	return
