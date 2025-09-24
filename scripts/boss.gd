extends "res://scripts/monster_base.gd"

@onready var ray_cast: RayCast2D = $RayCast
@onready var hit_box_collisionshape: CollisionShape2D = $HitBox/CollisionShape2D
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D

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
func _ready() -> void:
	super()

func _physics_process(delta: float) -> void:
	# Flip monster
	if ray_cast.is_colliding():
		flip_player()
		see_right(direction)
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
				animated_sprite.flip_h = true
				see_right(true)
			else:
				direction = -1
				animated_sprite.flip_h = false
				see_right(false)
	super(delta)
	
