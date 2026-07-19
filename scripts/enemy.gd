class_name Enemy
extends CharacterBody3D

@export var face_area : Area3D
@export var model_parent : Node3D

@export var death_sound: AudioStreamMP3 

@export_category("Movement")
@export var jump_force : float
@export var climbing_velocity : float
@export var speed = 5.0

@export_category("Enemy Data")
@export var max_health: float
@export var damage : int
@export var money : int

@export_group("Debug")
@export var climbing : bool
@export var should_jump : bool
@export var materials: Array[StandardMaterial3D]
@export var health: float

func _enter_tree() -> void:
	Constants.game_manager.enemies.append(self)

func _ready() -> void:
	face_area.body_entered.connect(on_body_entered)
	face_area.body_exited.connect(on_body_exited)
	set_process(false)

#Sets the values from enemies.json
func set_enemy_data(data : Dictionary) -> void:
	max_health = data["health"]
	damage = data["damage"]
	speed = data["walk_speed"]
	climbing_velocity = data["climb_speed"]
	jump_force = data["jump_height"]
	money = data["money"]
	scale = Vector3.ONE * float(data["scale"])

	var model_scene = load(data["path"])

	if model_scene and model_parent:
		var model = model_scene.instantiate() as Node3D
		model_parent.add_child(model)

		var animation_player = model.find_child("AnimationPlayer", true, false)
		if animation_player:
			for animation_name in animation_player.get_animation_list():
				if animation_name != "RESET":
					animation_player.get_animation(animation_name).loop_mode = Animation.LOOP_LINEAR
					animation_player.play(animation_name)
					break

		for node in model.find_children("*", "MeshInstance3D"):
			var mesh = node as MeshInstance3D
			var current_material = mesh.get_active_material(0)
			if current_material:
				var material_copy = current_material.duplicate()
				mesh.set_surface_override_material(0, material_copy)
				materials.append(material_copy)
	
	health = max_health
	set_process(true)

func _process(_delta: float) -> void:
	if health <= 0:
		_die()
		
func _die() -> void:
	var audio_player = AudioStreamPlayer3D.new()
	get_parent().add_child(audio_player)
	audio_player.bus = "Sounds"
	audio_player.stream = death_sound
	audio_player.play()
	audio_player.finished.connect(func(): audio_player.queue_free())

	queue_free()


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

func do_damage(amount:int) -> void:
	health -= amount

	var gb = health / max_health
	for material in materials:
		material.albedo_color = Color(1, gb, gb)
