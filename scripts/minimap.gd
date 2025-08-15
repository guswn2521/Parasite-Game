extends TextureRect

@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport
@onready var camera_2d: Camera2D = $SubViewportContainer/SubViewport/Camera2D
@onready var players_parent: Node2D = $"../../Players"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 서브 뷰포트가 표시할 world_2d를 최상위 루트 노드의 world_2d로 설정
	# world_2d: 2d environment(2d 세상)을 담고 있는 내장 속성
	sub_viewport.world_2d = get_tree().root.world_2d

	# 플레이어가 직접 보이는거 끄기
	# 대신 초록색 PlayerDot을 보이게 하기 위한 것.
	sub_viewport.set_canvas_cull_mask_bit(2, false)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var player = null
	var children = players_parent.get_children()
	if children.size() > 0:
		player = children[0]
	camera_2d.position = player.position + Vector2(0,100)
