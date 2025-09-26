extends "res://scripts/monster_base.gd"

@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var hit_box_collisionshape: CollisionShape2D = $HitBox/CollisionShape2D
@onready var collision_polygon_2d: CollisionPolygon2D = $MonsterArea/CollisionPolygon2D

func _ready() -> void:
	super()
	

func _physics_process(delta: float) -> void:
	# Flip monster
	if ray_cast_left.is_colliding():
		flip_player()
		see_right(direction)
	if ray_cast_right.is_colliding():
		flip_player()
		see_right(direction)
	
	# 낙사 방지
	check_fall_preventation()
	
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
				see_right(true)
			else:
				direction = -1
				animated_sprite.flip_h = true
				see_right(false)
	super(delta)
	
func see_right(direction:int) -> void:
	if direction==1:
		collision_polygon_2d.scale.x = 1
	else:
		collision_polygon_2d.scale.x = -1
