extends StaticBody3D

@export var eat_area: Area3D
@export var cake : Node3D

var game_manager : GameManager 

func _ready() -> void:
	#Initialize the signals and the global constants.
	game_manager = Constants.game_manager
	eat_area.body_entered.connect(on_body_entered)

func on_body_entered(body: Node3D) -> void:
	#If the collider is enemy class we destroy it and damage the tower
	if body is Enemy:
		body.set_physics_process(false)
		body.queue_free()
		game_manager.damage_tower(2)
		#Scale the cake down according to the max health
		var health_scale : float = (
			game_manager.tower_health/game_manager.max_tower_health)
		cake.scale = Vector3(health_scale, health_scale, health_scale)
