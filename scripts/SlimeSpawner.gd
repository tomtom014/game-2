extends Node2D

@export var slime_scene : PackedScene
@export var first_spawner : Marker2D
@export var second_spawner : Marker2D
@export var third_spawner : Marker2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_slime_timer_timeout() -> void:
	spawn_slime()

func spawn_slime() -> void:
	if slime_scene == null:
		print("i don't to sign slime_scene")
		return 
	var spawn_points : Array[Marker2D] = [first_spawner, second_spawner, third_spawner]
	var chosen_spawn : Marker2D = spawn_points.pick_random()
	if chosen_spawn == null:
		print("chosen_spawn didn't exist")
		return
	var slime := slime_scene.instantiate() as Node2D
	get_node("../ysort").add_child(slime)
	slime.global_position = chosen_spawn.global_position
