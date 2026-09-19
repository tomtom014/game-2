extends TileMapLayer

@export var player : CharacterBody2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == player or (player == null and body.is_in_group("player")):
		enabled = false
