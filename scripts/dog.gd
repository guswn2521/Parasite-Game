extends "res://scripts/monster_base.gd"

@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var hit_box_collisionshape: CollisionShape2D = $HitBox/CollisionShape2D
@onready var enemy_dot: Sprite2D = $EnemyDot

func _ready() -> void:
	super()
	enemy_dot.set_visibility_layer_bit(0, false) # 1번 끔
	enemy_dot.set_visibility_layer_bit(1, true) # 2번 켬
	animated_sprite.set_visibility_layer_bit(0, false) # 1번 끔
	animated_sprite.set_visibility_layer_bit(2, true) # 3번 켬
	monster_hp_bar.set_visibility_layer_bit(0, false) # 1번 끔
	monster_hp_bar.set_visibility_layer_bit(2, false) # 3번 켬

func _physics_process(delta: float) -> void:
	# Flip monster
	if ray_cast_left.is_colliding():
		flip_player()
	if ray_cast_right.is_colliding():
		flip_player()
	# Death
	if death:
		hit_box_collisionshape.disabled = true # 죽으면 공격 불가능하게
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
				animated_sprite.flip_h = false
			else:
				direction = -1
				animated_sprite.flip_h = true
	super(delta)
	
