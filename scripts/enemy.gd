class_name Enemy
extends CharacterBody3D

@export var face_area : Area3D
@export_category("Movement")
@export var jump_force : float
@export var climbing_velocity : float
@export var speed = 5.0

@export_group("Debug")
@export var climbing : bool
@export var should_jump : bool



func _ready() -> void:
	face_area.body_entered.connect(on_body_entered)
	face_area.body_exited.connect(on_body_exited)
	
func _physics_process(delta: float) -> void:
	if is_queued_for_deletion():
		return
	
	var target := Vector3(0,position.y,0)
	if position != target:
		look_at(target) 
	
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
	Constants.game_manager.current_enemy_count -= 1

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
