extends "res://scripts/monster_base.gd"

@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left_head: RayCast2D = $RayCastLeft_head
@onready var ray_cast_right_head: RayCast2D = $RayCastRight_head
@onready var animation_player: AnimationPlayer = $AttackAnimation
@onready var hit_box_collisionshape: CollisionShape2D = $HitBox/CollisionShape2D

func _ready()->void:
	super()
	animation_player.animation_finished.connect(_on_animation_player_animation_finished)

func _physics_process(delta: float) -> void:
	# Flip monster
	if ray_cast_left.is_colliding():
		flip_player()
	elif ray_cast_right.is_colliding():
		flip_player()
	elif ray_cast_left_head.is_colliding():
		flip_player()
	elif ray_cast_right_head.is_colliding():
		flip_player()
		
	# 낙사 방지
	check_fall_preventation()
		
	# Death
	if death:
		hit_box_collisionshape.disabled = true # 죽으면 공격 불가능하게
		return
	# Attack
	if in_attack_area and can_attack:
		attack_animation()
		can_attack = false
		print("attack timer start")
		attack_timer.start(1)
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
			else:
				direction = -1
				animated_sprite.flip_h = false
				
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
