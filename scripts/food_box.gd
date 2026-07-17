extends StaticBody3D

var game_manager : GameManager
@export var collison : Area3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_manager = Constants.game_manager



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
