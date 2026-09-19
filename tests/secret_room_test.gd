extends SceneTree

var _failures := 0
var _hits := 0


func _initialize() -> void:
	_run.call_deferred()


func _check(condition: bool, message: String) -> void:
	if condition:
		print("PASS: ", message)
	else:
		_failures += 1
		push_error(message)


func _run() -> void:
	var world := load("res://scene/world.tscn").instantiate() as Node2D
	root.add_child(world)
	current_scene = world
	world.get_node("SlimeSpawner/SlimeTimer").stop()
	var player := world.get_node("ysort/Player") as CharacterBody2D
	player.set_physics_process(false)
	player.connect("attack_landed", _on_attack)
	var secret := world.get_node("ysort/SecretRoom") as Node2D
	var entrance := secret.global_position
	await physics_frame
	await physics_frame
	_check(not secret.is_open and not secret.room.visible, "Room and chest are hidden on start")
	_check(is_instance_valid(secret.cracked_wall), "Crack exists before the hit")
	_check(secret.get_node("Room/Chest").get_used_cells().size() == 1, "Original chest is preserved")

	player.global_position = entrance + Vector2(0, 80)
	player.last_direction = Vector2.UP
	player.start_attack()
	await create_timer(0.7).timeout
	_check(not secret.is_open, "A distant attack does not reveal the room")

	player.global_position = entrance + Vector2(0, 23)
	player.last_direction = Vector2.DOWN
	player.start_attack()
	await create_timer(0.7).timeout
	_check(not secret.is_open, "Facing away does not reveal the room")
	_check(player.test_move(player.global_transform, Vector2(0, -36)), "Closed entrance blocks the player")

	player.last_direction = Vector2.UP
	var hits_before := _hits
	player.start_attack()
	_check(not secret.is_open, "Attack wind-up does not reveal the room before the impact frame")
	await create_timer(0.7).timeout
	await physics_frame
	_check(secret.is_open and secret.room.visible, "A nearby sword hit reveals the room and chest")
	_check(_hits == hits_before + 1, "Only one hit is emitted per attack animation")
	_check(not is_instance_valid(secret.cracked_wall), "Crack and sealed-room collision are removed")
	_check(not player.test_move(player.global_transform, Vector2(0, -36)), "Opened passage lets the player enter")
	player.move_and_collide(Vector2(0, -36))
	_check(player.global_position.y < entrance.y, "Player can physically walk into the secret")
	_check(player.test_move(player.global_transform, Vector2(0, -60)), "Room's outer walls stay solid")
	secret.open_secret()
	_check(secret.is_open, "Repeated opening is harmless")
	world.queue_free()
	await process_frame
	print("Secret room checks complete. Failures: ", _failures)
	quit(0 if _failures == 0 else 1)


func _on_attack(_origin: Vector2, _direction: Vector2, _reach: float) -> void:
	_hits += 1
