class_name GameManager
extends Node

@export var tower : Node3D

func _ready() -> void:
	Constants.game_manager = self
