extends Control

@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport
@onready var camera_2d: Camera2D = $SubViewportContainer/SubViewport/Camera2D
@onready var players_parent: Node2D = $"../../Players"
@onready var player_dot: Sprite2D = $PlayerDot

func _ready() -> void:
	# 서브 뷰포트가 표시할 world_2d를 최상위 루트 노드의 world_2d로 설정
	# world_2d: 2d environment(2d 세상)을 담고 있는 내장 속성
	sub_viewport.world_2d = get_tree().root.world_2d
	#get_viewport().canvas_cull_mask &= ~2  # 2번 비트 끄기
	sub_viewport.set_canvas_cull_mask_bit(1,true)
	sub_viewport.set_canvas_cull_mask_bit(0,true)
	

func _process(delta: float) -> void:
	var player = null
	var children = players_parent.get_children()
	if children.size() > 0:
		player = children[0]
	camera_2d.position = player.position + Vector2(0,40)
