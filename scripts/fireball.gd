extends Area2D

@export var speed: float = 300
@export var direction: int  # 1: 오른쪽, -1: 왼쪽
var start_position: Vector2
var animated_sprite: AnimatedSprite2D

func _ready() -> void:
	z_index = -1
	animated_sprite = $AnimatedSprite2D

	start_position = global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += speed * delta * direction


	
func set_left(is_left: int)-> void:
	if is_left:
		direction = -1
		animated_sprite.flip_h = true
	else:
		direction = 1
	


func _on_body_entered(body: Node2D) -> void:
	print(body)
	pass # Replace with function body.
