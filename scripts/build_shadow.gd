class_name BuildShadow
extends Area3D

@export var placable_material: Material 
@export var obstructed_material: Material 

@export var object: Node3D

@export_group("Debug")

@export var max_range_indicator: MaxRangeIndicator
@export var meshes: Array[MeshInstance3D] = []
@export var colliding: int = 0

func setup(_meshes: Array[MeshInstance3D], range_indicator_radius: float) -> void:
	max_range_indicator = Constants.game_manager.player.max_range_indicator

	meshes = _meshes
	if meshes.is_empty():
		push_error("BuildShadow has no meshes assigned")

	area_entered.connect(func(_body: Node3D): colliding += 1)
	area_exited.connect(func(_body: Node3D): colliding -= 1)

	max_range_indicator.setup(range_indicator_radius, object)
	show_as_placable()

func is_colliding() -> bool:
	return 0 < colliding

func show_as_placable() -> void:
	for mesh in meshes:
		mesh.material_override = placable_material
		mesh.show()
	max_range_indicator.show()

func show_as_obstructed() -> void:
	for mesh in meshes:
		mesh.material_override = obstructed_material 
		mesh.show()
	max_range_indicator.show()

func hide_shadow() -> void:
	for mesh in meshes:
		mesh.hide()
	max_range_indicator.hide()

func _exit_tree() -> void:
	if max_range_indicator:
		max_range_indicator.hide()
	object.queue_free()
