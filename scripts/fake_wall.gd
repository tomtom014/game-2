extends TileMapLayer

@export var more_dungeon_stuff: TileMapLayer
@export var crack_point: Marker2D
# Optional: a separate body blocking the entrance or the hidden room.
@export var blocking_body: StaticBody2D

var is_open := false


func _ready() -> void:
	if more_dungeon_stuff == null or crack_point == null:
		push_error("FakeWall: assign More Dungeon Stuff and Crack Point in Inspector.")
		return
	enabled = true
	more_dungeon_stuff.enabled = false


func _on_player_attack_landed(origin: Vector2, direction: Vector2, reach: float) -> void:
	if is_open or more_dungeon_stuff == null or crack_point == null:
		return

	var to_crack := crack_point.global_position - origin
	if to_crack.length() > reach + 8.0:
		return
	if direction.dot(to_crack.normalized()) < 0.6:
		return

	open_secret()


func open_secret() -> void:
	if is_open or more_dungeon_stuff == null:
		return

	is_open = true
	enabled = false
	more_dungeon_stuff.enabled = true
	if is_instance_valid(blocking_body):
		blocking_body.queue_free()
