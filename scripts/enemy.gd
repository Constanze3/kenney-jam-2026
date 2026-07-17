class_name Enemy
extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var face_area : Area3D
@export var should_jump : bool
@export var jump_force : float

func _ready() -> void:
	face_area.body_entered.connect(on_body_entered)
func _physics_process(delta: float) -> void:
	# Add the gravity.	
	if not is_on_floor():
		velocity += get_gravity() * delta
	if should_jump and is_on_floor():
		velocity += Vector3.UP * jump_force
		should_jump = false
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
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
	return
func on_body_entered(body: Node3D) -> void:
	if body is Enemy and body.name != name:
		should_jump = true
	if body == Constants.game_manager.tower:
		print("TOWER")
		return
