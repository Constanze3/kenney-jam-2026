extends StaticBody3D

@export var eat_area: Area3D
@export var cake : Node3D
var game_manager : GameManager 
var x : int

func _ready() -> void:
	game_manager = Constants.game_manager
	eat_area.body_entered.connect(on_body_entered)
	print(game_manager)

func on_body_entered(body: Node3D) -> void:
	if body is Enemy:
		x += 1
		body.set_physics_process(false)
		body.queue_free()
		print(x)
		game_manager.damage_tower(2)
		var health_scale : float = game_manager.tower_health/game_manager.max_tower_health
		cake.scale = Vector3(health_scale, health_scale, health_scale)
