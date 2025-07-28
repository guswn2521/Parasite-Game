extends Button

@onready var players_parent: Node2D = $"../../Players"
var PLAYER_SCENE = preload("res://scenes/player.tscn")

func _ready() -> void:
	# 포커스 받으면, 엔터, 스페이스바 눌러도 눌려서, 포커스 안받게
	self.focus_mode = Control.FOCUS_NONE
	self.pressed.connect(duplicate_player)

func duplicate_player() -> void:
	var origin_player = null
	var children = players_parent.get_children()
	if children.size() > 0:
		origin_player = children[0]
	else:
		print("No origin player!")
		return
	# 새 플레이어 인스턴스 생성
	var new_player = PLAYER_SCENE.instantiate()
	# 첫 번쨰 플레이어 위치 복사
	new_player.position = origin_player.position
	# 부모 노드(Players)에 새 노드 추가
	players_parent.add_child(new_player)
