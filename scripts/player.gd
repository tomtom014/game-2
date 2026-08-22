extends CharacterBody2D

@export var sprite: AnimatedSprite2D
@export var movement_speed: float = 100.0

@export var anim_move_right := "move_right"
@export var anim_move_up := "move_up"
@export var anim_move_down := "move_down"
@export var anim_idle_right := "idle_right"
@export var anim_idle_up := "idle_up"
@export var anim_idle_down := "idle_down"
@export var anim_attack_right := "attack_right"
@export var anim_attack_up := "attack_up"
@export var anim_attack_down := "attack_down"
@export var anim_die := "die"

var character_direction := Vector2.ZERO
var last_direction := Vector2.DOWN
var is_attacking := false
var is_dead := false


func _ready() -> void:
	if not sprite:
		sprite = get_node_or_null("sprite") as AnimatedSprite2D
	if sprite and not sprite.animation_finished.is_connected(_on_animation_finished):
		sprite.animation_finished.connect(_on_animation_finished)


func _physics_process(_delta: float) -> void:
	if is_dead:
		velocity = Vector2.ZERO
		return
	if Input.is_action_just_pressed("attack") and not is_attacking:
		start_attack()
	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	character_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if character_direction != Vector2.ZERO:
		last_direction = character_direction
		velocity = character_direction * movement_speed
		update_animation(true)
	else:
		velocity = Vector2.ZERO
		update_animation(false)
	move_and_slide()


func update_animation(is_moving: bool) -> void:
	if not sprite:
		return
	var animation_to_play: String
	if abs(last_direction.y) > abs(last_direction.x):
		sprite.flip_h = false
		if last_direction.y < 0.0:
			animation_to_play = anim_move_up if is_moving else anim_idle_up
		else:
			animation_to_play = anim_move_down if is_moving else anim_idle_down
	else:
		sprite.flip_h = last_direction.x < 0.0
		animation_to_play = anim_move_right if is_moving else anim_idle_right
	if sprite.animation != animation_to_play or not sprite.is_playing():
		sprite.play(animation_to_play)


func start_attack() -> void:
	if not sprite:
		return
	is_attacking = true
	velocity = Vector2.ZERO
	var animation_to_play: String
	if abs(last_direction.y) > abs(last_direction.x):
		sprite.flip_h = false
		animation_to_play = anim_attack_up if last_direction.y < 0.0 else anim_attack_down
	else:
		sprite.flip_h = last_direction.x < 0.0
		animation_to_play = anim_attack_right
	sprite.play(animation_to_play)


func die() -> void:
	is_dead = true
	is_attacking = false
	velocity = Vector2.ZERO
	if sprite:
		sprite.play(anim_die)


func _on_animation_finished() -> void:
	if sprite and sprite.animation in [anim_attack_up, anim_attack_down, anim_attack_right]:
		is_attacking = false
		update_animation(false)
