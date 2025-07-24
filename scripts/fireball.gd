extends Area2D

@export var speed: float = 300
@export var direction: int  # 1: 오른쪽, -1: 왼쪽
var start_position: Vector2
var animated_sprite: AnimatedSprite2D
var monster: Node

func _ready() -> void:
	z_index = -1
	animated_sprite = $AnimatedSprite2D

	start_position = global_position
	connect("area_entered", Callable(self, "_on_area_entered"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += speed * delta * direction


	
func set_left(is_left: int)-> void:
	if is_left:
		direction = -1
		animated_sprite.flip_h = true
	else:
		direction = 1


func _on_area_entered(area: Area2D) -> void:
	monster = area.get_parent()
	if monster.is_in_group("Monsters"):
		monster.death_motion()
	
