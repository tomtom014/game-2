extends Area2D

@export var destination:Marker2D

func _unhandled_input(event: InputEvent) -> void:
	if destination == null or not event.is_action_pressed("interact"):
		return
	for body in get_overlapping_bodies():
		if body.is_in_group("player") and not body.is_dead:
			body.velocity = Vector2.ZERO
			body.global_position = destination.global_position
			get_viewport().set_input_as_handled()
			return
