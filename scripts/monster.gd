extends CharacterBody2D

var direction = 1
var SPEED = 60
var gravity = 300
var death = false
var is_hurt = false
var on_attack = false
var in_attack_zone = false
var can_attack: bool = true
var in_chase = false
var hurt_duration = 0.5 # 애니메이션 길이에 맞춰서 수정
var knockback_velocity = Vector2.ZERO
var knockback_power = 200 # 원하는 값으로 조정
var maxHP = 300
var monster_attack_damage = 60
#var in_attack_zone = false
@onready var currentHP: int = maxHP
@onready var hurt_timer: Timer = $HurtTimer
@onready var attack_timer: Timer = $AttackTimer

@onready var player: CharacterBody2D = $"../../Players/player"
@onready var monster_area: Area2D = $MonsterArea
@onready var collision_shape: CollisionShape2D = $MonsterArea/CollisionShape2D
@onready var ray_cast_left: RayCast2D = $MonsterArea/RayCast2D_left
@onready var ray_cast_right: RayCast2D = $MonsterArea/RayCast2D_right
@onready var ray_cast_bottom: RayCast2D = $MonsterArea/RayCast2D_bottom

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animated_attack_left: AnimatedSprite2D = $attack_left
@onready var animated_attack_right: AnimatedSprite2D = $attack_right
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var monster_hit_box: CollisionShape2D = $HitboxPivot/WeaponHitbox/CollisionShape2D
@onready var hurtbox_collision_shape: CollisionShape2D = $Hurtbox/CollisionShape2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@onready var monster_hp_bar: TextureProgressBar = $TextureProgressBar
@export var item_scene: PackedScene


var DAMAGE_NUMBER_SCENE = preload("res://scenes/damage_number.tscn")
var rng = RandomNumberGenerator.new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("Monsters")
	monster_hp_bar.max_value = maxHP
	monster_hp_bar.value = currentHP

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if death:
		monster_hit_box.disabled = true
		return
	
	if is_hurt:
		position += knockback_velocity * delta
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 500 * delta)
	
	if in_attack_zone and can_attack:
		attack_animation()
		can_attack = false
		attack_timer.start()
		
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if ray_cast_left.is_colliding():
		direction = -1
		animated_sprite.flip_h = false
		
	if ray_cast_right.is_colliding():
		direction = 1
		animated_sprite.flip_h = true
		
	if in_chase:
		var distance = player.position.x - position.x
		if abs(distance) < 10:
			velocity.x = 0
		else:
			if distance > 0:
				direction =  1
				animated_sprite.flip_h = true
			else:
				direction = -1
				animated_sprite.flip_h = false
	velocity.x = direction * SPEED
	if on_attack:
		velocity.x = 0
	move_and_slide()
	# Play Animation
	if not on_attack:
		animated_sprite.play("walk")
	if is_hurt:
		animated_sprite.visible = true
		animated_attack_left.visible = false
		animated_attack_right.visible = false
	if death:
		if animated_sprite.animation != "death":
			animated_sprite.play("death")

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
	
	var damage_number = DAMAGE_NUMBER_SCENE.instantiate()
	get_parent().add_child(damage_number)
	# 머리 위에 damage_number
	damage_number.global_position = global_position + Vector2(0, -75)
	damage_number.show_damage(damage, is_critical)
	if currentHP <= 0:
		animated_sprite.visible = true
		animated_attack_left.visible = false
		animated_attack_right.visible = false
		print("death start")
		death_motion()
	else:
		hurt_motion(direction)
		
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

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "death":
		print("death")
		drop_item()
		queue_free()

func drop_item():
	var item = item_scene.instantiate()
	item.position = position + Vector2(0,-20)
	get_tree().root.add_child(item)

# Hurtbox에 플레이어 들어오면 Chase
func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.name == "player":
		print("chase")
		in_chase = true

func _on_hurtbox_body_exited(body: Node2D) -> void:
	print("체이스 종료==========")
	in_chase = false

# MonsterArea 에 플레이어가 들어오면 Attack
func _on_monster_area_body_entered(body: Node2D) -> void:
	if body.name == "player":
		print("monster attack area")
		in_attack_zone = true

func _on_monster_area_body_exited(body: Node2D) -> void:
	if body.name == "player":
		print("player exit attack area")
		in_attack_zone = false

func attack_animation():
	if not can_attack:
		return
	if animated_sprite.animation == "attack":
		return
	if not animation_player.current_animation in ["AttackLeft","AttackRight"]:
		on_attack = true
		animated_sprite.visible=false
		if position.x - player.position.x > 0:
			# 플레이어가 왼쪽에서 다가옴
			direction = -1
			animated_sprite.flip_h = false
			animated_attack_left.visible = true
			animation_player.play("AttackLeft")
			animated_attack_left.play("attack")
				
		elif position.x - player.position.x < 0:
			# 플레이어가 오른쪽에서 다가옴
			direction = 1
			animation_player.play("AttackRight")
			animated_attack_right.visible = true
			animated_attack_right.play("attack")

func _on_attack_timer_timeout() -> void:
	print("attack timer fin")
	can_attack = true

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name in ["AttackLeft", "AttackRight"]:
		on_attack = false
		animated_sprite.visible = true
		animated_attack_right.visible = false
		animated_attack_left.visible = false

func _on_weapon_hitbox_body_entered(body: Node2D) -> void:
	print("attack ",monster_attack_damage)
	if body.is_in_group("Players"):
		body.take_damage(direction, monster_attack_damage)
