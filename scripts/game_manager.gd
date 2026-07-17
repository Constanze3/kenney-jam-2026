class_name GameManager
extends Node

@export var tower : Node3D
@export var max_tower_health : float
@export var tower_health : float
@export var cake : Node3D
func _ready() -> void:
	tower_health = max_tower_health
	Constants.game_manager = self
