extends Node
@export var enemy_scene : PackedScene
@export var spawn_radius : float
var angle : float
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in 40:
		_spawn_enemy()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _spawn_enemy() -> void:
	var new_enemy := enemy_scene.instantiate() as Node3D
	add_child(new_enemy) 
	angle = randf() * TAU
	new_enemy.global_position =  (Vector3 (
			cos(angle) * spawn_radius, 
			10.0, 
			sin(angle) * spawn_radius 
			))
 
