class_name Enemy
extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var face_area : Area3D
@export var should_jump : bool
@export var jump_force : float
@export var climbing : bool
@export var climbing_velocity : float

func _ready() -> void:
	face_area.body_entered.connect(on_body_entered)
	face_area.body_exited.connect(on_body_exited)
func _physics_process(delta: float) -> void:
	
	# Add the gravity.	
	if not is_on_floor() and not climbing:
		velocity += get_gravity() * delta
	
	if should_jump and is_on_floor() and not climbing:
		velocity += Vector3.UP * jump_force
		should_jump = false 
	
	if climbing:
		climb()
	
	var direction := (Vector3(0,30,0) - position).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		look_at(Vector3(0,position.y,0)) 
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func climb() -> void:
	velocity.y = climbing_velocity

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
