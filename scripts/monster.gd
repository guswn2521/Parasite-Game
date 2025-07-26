extends Node2D

var direction = 1
var SPEED = 60
var gravity = 300
var death = false
var is_hurt = false
var on_attack = false
var in_chase = false
var hurt_duration = 0.5 # 애니메이션 길이에 맞춰서 수정
var knockback_velocity = Vector2.ZERO
var knockback_power = 200 # 원하는 값으로 조정
var maxHP = 1000
var damage = 60

@onready var currentHP: int = maxHP
@onready var hurt_timer: Timer = $HurtTimer
@onready var attack_timer: Timer = $AttackTimer

@onready var player: CharacterBody2D = $"../../player"
@onready var collision_shape: CollisionShape2D = $MonsterArea/CollisionShape2D
@onready var ray_cast_left: RayCast2D = $MonsterArea/RayCast2D_left
@onready var ray_cast_right: RayCast2D = $MonsterArea/RayCast2D_right
@onready var ray_cast_bottom: RayCast2D = $MonsterArea/RayCast2D_bottom

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var monster_hp_bar: TextureProgressBar = $TextureProgressBar

signal is_on_floor

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("Monsters")
	monster_hp_bar.max_value = maxHP
	monster_hp_bar.value = currentHP

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_hurt:
		position += knockback_velocity * delta
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 500 * delta)
	
	if death:
		return
	
	if not ray_cast_bottom.is_colliding():
		position.y += gravity * delta
		
	if ray_cast_left.is_colliding():
		direction = -1
		animated_sprite.flip_h = false
		
	if ray_cast_right.is_colliding():
		direction = 1
		animated_sprite.flip_h = true
		
	if in_chase:
		var distance = player.position.x - position.x
		if distance > 0:
			direction =  1
			animated_sprite.flip_h = true
		else:
			direction = -1
			animated_sprite.flip_h = false

	if on_attack:
		animated_sprite.play("attack")
	else:
		animated_sprite.play("walk")
		position.x += direction * SPEED * delta

func take_damage(direction:int, damage: int) -> void:
	currentHP -= damage
	monster_hp_bar.value = currentHP
	if currentHP <= 0:
		death_motion()
	else:
		hurt_motion(direction)
		
func hurt_motion(direction: int) -> void:
	print("hurt")
	is_hurt = true
	animated_sprite.play("hurt")
	knockback_velocity = Vector2(direction,0) * knockback_power
	hurt_timer.start(0.4)

func _on_hurt_timer_timeout() -> void:
	if not death:
		is_hurt = false
		knockback_velocity = Vector2.ZERO
		# 한 대 맞은거 끝나면 다시 걷기 실행.
		animated_sprite.play("walk")

func death_motion() -> void:
	animated_sprite.play("death")
	death = true
	SPEED = Vector2.ZERO

func _on_animated_sprite_2d_animation_finished() -> void:
	print("death")
	if animated_sprite.animation == "death":
		queue_free()

# Hurtbox에 플레이어 들어오면
func _on_hurtbox_body_entered(body: Node2D) -> void:
	print("hurtbox area")
	if body is CharacterBody2D:
		in_chase = true
		print("chasing")

func _on_hurtbox_body_exited(body: Node2D) -> void:
	in_chase = false
	print("chase 끝남")

# MonsterArea 에 플레이어가 들어오면
func _on_area_2d_body_entered(body: Node2D) -> void:
	print("monster area")
	if body is CharacterBody2D:
		on_attack=true
		attack(body)

func attack(body):
	if position.x - body.position.x > 0:
		print("플레이어가 왼쪽에서 다가옴")
		animation_player.play("AttackLeft")
		direction = -1
		animated_sprite.flip_h = false
			
	elif position.x - body.position.x < 0:
		print("플레이어가 오른쪽에서 다가옴")
		animation_player.play("AttackRight")
		direction = 1
		animated_sprite.flip_h = true
	player.hp -= damage
	print(player.hp)

func _on_attack_finished(anim_name: StringName) -> void:
	## attack 애니메이션이었으면
	if anim_name == "AttackRight" or anim_name == "AttackLeft":
		## 플레이어가 죽었으면
		if player.hp <= 0:
			player.is_dead = true
			on_attack = false
			animation_player.play("RESET")
			print("attack animation finished")
		else:
			attack(player)
