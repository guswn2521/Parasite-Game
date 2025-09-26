extends "res://scripts/monster_base.gd"

@onready var ray_cast: RayCast2D = $RayCast
@onready var hit_box_collisionshape: CollisionShape2D = $HitBox/CollisionShape2D
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D
@onready var animation_player: AnimationPlayer = $AttackAnimation


signal boss_died

func _ready() -> void:
	monster_attack_damage = 100
	maxHP = 1000
	animation_player.animation_finished.connect(_on_animation_player_animation_finished)
	super()

func _physics_process(delta: float) -> void:
	# Flip monster
	if ray_cast.is_colliding():
		flip_player()
		see_right(direction)
	# Death
	if death:
		hit_box_collisionshape.disabled = true # 죽으면 공격 불가능하게
		emit_signal("boss_died")
		return
	# Chase
	if in_chase:
		var player = players_parent.get_children()[0]
		var distance = player.position.x - position.x
		if abs(distance) <= 10:
			velocity.x = 0
		else:
			if distance > 0:
				direction = 1
				animated_sprite.flip_h = true
				see_right(true)
			else:
				direction = -1
				animated_sprite.flip_h = false
				see_right(false)
	# Attack
	if in_attack_area and can_attack:
		attack_animation()
		can_attack = false
		attack_timer.start(1)
	super(delta)
	
func attack_animation():
	if not can_attack:
		return
	if animated_sprite.animation == "attack":
		return
	if not animation_player.current_animation in ["attack_left","attack_right"]:
		on_attack = true
		var player = players_parent.get_children()[0]
		if position.x - player.position.x > 0:
			# 플레이어가 왼쪽에서 다가옴
			direction = -1
			animated_sprite.flip_h = false
			#animated_attack_left.visible = true
			animation_player.play("attack_left")
			animated_sprite.play("attack")
				
		elif position.x - player.position.x < 0:
			# 플레이어가 오른쪽에서 다가옴
			direction = 1
			animation_player.play("attack_right")
			#animated_attack_right.visible = true
			animated_sprite.flip_h = true
			animated_sprite.play("attack")
			
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name in ["attack_left","attack_right"]:
		on_attack = false

func see_right(direction:int) -> void:
	if direction==1:
		collision_polygon_2d.scale.x = -1
		collision_polygon_2d.position = collision_polygon_2d.facing_right_position
		ray_cast.position = ray_cast.facing_right_position
		ray_cast.target_position = ray_cast.target_right_position
	else:
		collision_polygon_2d.scale.x = 1
		collision_polygon_2d.position = collision_polygon_2d.facing_left_position
		ray_cast.position = ray_cast.facing_left_position
		ray_cast.target_position = ray_cast.target_left_position
