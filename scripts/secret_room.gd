extends Node2D

@export var room: Node2D
@export var cracked_wall: StaticBody2D
@export var break_particles: CPUParticles2D

var is_open := false


func _ready() -> void:
	room.hide()


func _on_player_attack_landed(origin: Vector2, direction: Vector2, reach: float) -> void:
	if is_open:
		return

	var to_crack := cracked_wall.global_position - origin
	if to_crack.length() > reach + 8.0:
		return
	if direction.dot(to_crack.normalized()) < 0.6:
		return

	open_secret()


func open_secret() -> void:
	if is_open:
		return

	is_open = true
	room.show()
	cracked_wall.queue_free()
	if break_particles:
		break_particles.emitting = true
