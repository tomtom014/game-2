extends TileMapLayer

@export var player : CharacterBody2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == player:
		enabled = false
