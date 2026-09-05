extends CharacterBody2D

@export var max_speed: float = 20.0
@export var acceleration: float = 300.0
@export var animated_sprite: AnimatedSprite2D


func _ready():
	if animated_sprite == null:
		animated_sprite = get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D


func _physics_process(delta):
	var direction = get_direction_to_player()
	var target_velocity = max_speed * direction
	velocity = velocity.move_toward(target_velocity,acceleration * delta)
	move_and_slide()
	update_animation()


func update_animation():
	if animated_sprite == null:
		return
	if velocity.length_squared() > 0.01:
		animated_sprite.play("run")
		if abs(velocity.x) > 0.01:
			animated_sprite.flip_h = velocity.x < 0
	else:
		animated_sprite.play("idle")

func get_direction_to_player():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player != null:
		return (player.global_position - global_position).normalized()
	return Vector2(0,0)
	
