extends Area2D

@export var speed: float = 300
@export var direction: int  # 1: 오른쪽, -1: 왼쪽
var start_position: Vector2
var animated_sprite: AnimatedSprite2D
var monster: Node
var hit = false
var attack_power = 1000

func _ready() -> void:
	z_index = 1
	animated_sprite = $AnimatedSprite2D
	start_position = global_position
	if not is_connected("area_entered", Callable(self, "_on_area_entered")):
		connect("area_entered", Callable(self, "_on_area_entered"))

func set_left(is_left: int)-> void:
	if is_left:
		direction = -1
		animated_sprite.flip_h = true
		global_position += Vector2(-160,0)
	else:
		direction = 1

func _on_area_entered(area: Area2D) -> void:
	monster = area.get_parent()
	if monster.is_in_group("Monsters"):
		monster.take_damage(direction, attack_power)
		hit = true
