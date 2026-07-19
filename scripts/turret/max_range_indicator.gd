class_name MaxRangeIndicator
extends MeshInstance3D

@export_group("Debug")

@export var _radius: float
@export var _target: Node3D

func _ready() -> void:
	_set_target(null)

func _process(_delta: float) -> void:
	if _target:
		global_position = _target.global_position

func setup(radius: float, target: Node3D):
	_set_radius(radius)
	_set_target(target)
	show()

func _set_radius(value: float):
	transform.scaled(Vector3.ONE * value)
	_radius = value

func _set_target(value: Node3D):
	if not value:
		hide()
	else:
		show()

	_target = value
