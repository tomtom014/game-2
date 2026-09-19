extends Node2D

@export_category("Slime")
@export var slime_scene: PackedScene
@export var enemies_parent: Node

@export_category("Spawn points")
@export var spawn_point_1: Marker2D
@export var spawn_point_2: Marker2D
@export var spawn_point_3: Marker2D

@export_category("Timer")
@export var spawn_timer: Timer
@export_range(0.1, 60.0, 0.1, "suffix:s") var spawn_interval: float = 5.0


func _ready() -> void:
	if spawn_timer == null:
		push_error("SlimeSpawner: Spawn Timer не назначен в Inspector")
		return

	spawn_timer.wait_time = spawn_interval
	spawn_timer.one_shot = false
	if not spawn_timer.timeout.is_connected(spawn_slime):
		spawn_timer.timeout.connect(spawn_slime)
	spawn_timer.start()


func spawn_slime() -> void:
	if slime_scene == null:
		push_error("SlimeSpawner: Slime Scene не назначена в Inspector")
		return
	if enemies_parent == null:
		push_error("SlimeSpawner: Enemies Parent не назначен в Inspector")
		return

	var configured_points: Array[Marker2D] = [
		spawn_point_1,
		spawn_point_2,
		spawn_point_3,
	]
	var available_points: Array[Marker2D] = []
	for point: Marker2D in configured_points:
		if point != null:
			available_points.append(point)

	if available_points.is_empty():
		push_error("SlimeSpawner: точки спавна не назначены")
		return

	var selected_point: Marker2D = available_points.pick_random()
	var slime := slime_scene.instantiate() as Node2D
	if slime == null:
		push_error("SlimeSpawner: корень Slime Scene должен наследоваться от Node2D")
		return

	enemies_parent.add_child(slime)
	slime.global_position = selected_point.global_position
