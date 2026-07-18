class_name GameManager
extends Node

@export var tower : Node3D
@export var max_tower_health : float
@export var tower_health : float
func _enter_tree() -> void:
	Constants.game_manager = self

func _ready() -> void:
	tower_health = max_tower_health

func damage_tower (damage_amount : int) -> void:
	tower_health = tower_health - damage_amount
