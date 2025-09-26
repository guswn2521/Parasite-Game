extends CharacterBody2D

var direction = 1
var SPEED = 80
var gravity = 300
var in_chase = false
var in_attack_area = false
var on_attack = false
var can_attack: bool = true
var is_hurt = false
var knockback_velocity = Vector2.ZERO
var knockback_power = 200 # 원하는 값으로 조정
var death = false
var maxHP = 300
var monster_attack_damage = 5

var DAMAGE_NUMBER_SCENE = preload("res://scenes/damage_number.tscn")
var rng = RandomNumberGenerator.new()

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var players_parent: Node2D = $"../../Players"
@onready var chase_area: Area2D = $ChaseArea
@onready var attack_area: Area2D = $AttackArea
@onready var attack_timer: Timer = $AttackTimer
@onready var hit_box: Area2D = $HitBox
@onready var hurt_timer: Timer = $HurtTimer
@onready var currentHP: int = maxHP
@onready var monster_hp_bar: TextureProgressBar = $TextureProgressBar
@onready var enemy_dot: Sprite2D = $EnemyDot

func _ready() -> void:
	add_to_group("Monsters")
	# signal connect
	chase_area.body_entered.connect(_on_chase_area_body_entered)
	chase_area.body_exited.connect(_on_chase_area_body_exited)
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	attack_area.body_exited.connect(_on_attack_area_body_exited)
	hit_box.body_entered.connect(_on_hitbox_body_entered)
	attack_timer.timeout.connect(_on_attack_timeout)
	hurt_timer.timeout.connect(_on_hurt_timer_timeout)
	animated_sprite.animation_finished.connect(_on_animation_finished)
	
	# set visibility
	enemy_dot.set_visibility_layer_bit(0, false) # 1번 끔
	enemy_dot.set_visibility_layer_bit(1, true) # 2번 켬
	animated_sprite.set_visibility_layer_bit(0, false) # 1번 끔
	animated_sprite.set_visibility_layer_bit(2, true) # 3번 켬
	monster_hp_bar.set_visibility_layer_bit(0, false) # 1번 끔
	monster_hp_bar.set_visibility_layer_bit(2, true) # 3번 켬
	
	# set HP
	monster_hp_bar.max_value = maxHP
	monster_hp_bar.value = currentHP
	
func _physics_process(delta: float) -> void:
	# Hurt
	if is_hurt:
		position += knockback_velocity * delta
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 500 * delta)
		return
		
	# Default Velocity
	velocity.x = direction * SPEED
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	#print(direction, SPEED)
	move_and_slide()
	
	
	# Play Animation
	if not on_attack:
		animated_sprite.play("run")
	if death:
		if animated_sprite.animation != "death":
			animated_sprite.play("death")
			
func flip_player():
	direction *= -1
	animated_sprite.flip_h = not animated_sprite.flip_h

func _on_chase_area_body_entered(body: Node2D) -> void:
	if "player" in body.name:
		#print("Mushroom chase 시작: ", body.name)
		in_chase = true
	
func _on_chase_area_body_exited(body: Node2D) -> void:
	if "player" in body.name:
		#print("Mushrrom chase 끝")
		in_chase = false
		
func _on_attack_area_body_entered(body:Node2D) -> void:
	if "player" in body.name:
		#print("attack area body entered")
		in_attack_area = true
	
func _on_attack_area_body_exited(body:Node2D) -> void:
	if "player" in body.name:
		#print("attack area body exited")
		in_attack_area = false

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players"):
		#print("Mushroom Attack success")
		body.take_damage(direction, monster_attack_damage)
		
func _on_attack_timeout() -> void:
	#print("attack timer fin")
	can_attack = true
	
func hurt_motion(direction: int) -> void:
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

func apply_damage(base_damage:int) -> Array:
	rng.randomize()
	var ciritical_chance = 0.4
	var is_critical = rng.randf() <= ciritical_chance
	var damage = rng.randi_range(base_damage, base_damage+30)
	if is_critical:
		damage *= 2
	return [damage, is_critical]
	
func take_damage(direction:int, damage: int) -> void:
	var result = apply_damage(damage)
	damage = result[0]
	var is_critical = result[1]
	currentHP -= damage
	monster_hp_bar.value = currentHP
	print("몬스터 맞음", currentHP)
	var damage_number = DAMAGE_NUMBER_SCENE.instantiate()
	get_parent().add_child(damage_number)
	# 머리 위에 damage_number
	damage_number.global_position = global_position + Vector2(0, -75)
	damage_number.show_damage(damage, is_critical)
	if currentHP <= 0:
		death_motion()
	else:
		hurt_motion(direction)

func _on_animation_finished() -> void:
	if animated_sprite.animation == "death":
		print("death")
		queue_free()
