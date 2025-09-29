extends Area2D

@export var speed: float = 300
@export var max_distance: float = 100 # 사거리 설정
var direction: int  # 1: 오른쪽, -1: 왼쪽
var start_position: Vector2
var animated_sprite: AnimatedSprite2D
var monster: Node
var hit = false
var attack_power = 100

func _ready() -> void:
	z_index = 1
	animated_sprite = $AnimatedSprite2D
	if not is_connected("area_entered", Callable(self, "_on_area_entered")):
		connect("area_entered", Callable(self, "_on_area_entered"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not hit:
		position.x += speed * delta * direction
		if start_position.distance_to(global_position) >= max_distance:
			queue_free()

	
func set_left(is_left: int)-> void:
	if is_left:
		direction = -1
		animated_sprite.flip_h = true
	else:
		direction = 1


func _on_area_entered(area: Area2D) -> void:
	monster = area.get_parent()
	# 몬스터가 hit 된 동안 중복 데미지가 들어가서 not hit 조건문 추가
	if monster.is_in_group("Monsters") and not hit:
		print("FireBall -> monster HP: ", monster.currentHP)
		monster.take_damage(direction, attack_power)
		hit = true
		animated_sprite.play("explode")

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "explode":
		queue_free()
