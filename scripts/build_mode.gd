extends Node3D

@export var build_range: float = 2
@export_flags_3d_physics var raycast_collision_mask

@export var example: PackedScene

@export_group("Debug")

@export var enabled = false

@export var object_to_place: JSON
@export var shadow: Node3D

@export var can_place = false

func _ready() -> void:
	set_build_mode_enabled(false)
	# todo this is enabled
	set_object_to_place()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_build_mode"):
		set_build_mode_enabled(not enabled)

func set_build_mode_enabled(value: bool) -> void:
	enabled = value

	set_process(enabled)
	set_physics_process(enabled)

	if not enabled and shadow: 
		shadow.hide()
		
func _physics_process(_delta: float) -> void:
	show_shadow()

func set_object_to_place(): # object_data: JSON
	shadow = example.instantiate()
	add_child(shadow)
	shadow.hide()

func show_shadow():
	if not is_instance_valid(shadow):
		return

	var space_state = get_world_3d().direct_space_state
	var player := Constants.game_manager.player

	var camera_position = player.player_camera.global_position

	var query = PhysicsRayQueryParameters3D.create(
		camera_position,
		camera_position + (player.player_camera.global_basis * Vector3.FORWARD * build_range),
		raycast_collision_mask
	)
	query.hit_from_inside = true

	var result = space_state.intersect_ray(query)
	if result.is_empty():
		shadow.hide()
		return

	if result["normal"] != Vector3.UP:
		return

	shadow.show()
	shadow.global_position = result["position"]


func spawn_object():
	pass	
