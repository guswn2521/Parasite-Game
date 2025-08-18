extends Button
@onready var game: Node2D = get_node("/root/Game")
@onready var players_parent: Node2D = $"../../../Players"
var EVOLVED_PLAYER_SCENE = preload("res://scenes/evolved_player.tscn")
var evolution_effect = preload("res://scenes/evolution.tscn")
signal no_evolution

func _ready() -> void:
	# 포커스 받으면, 엔터, 스페이스바 눌러도 눌려서, 포커스 안받게
	self.focus_mode = Control.FOCUS_NONE
	self.pressed.connect(evolve_player)

func spawn_evolution_effect(player_position:Vector2) -> void:
	var evolution_fx = evolution_effect.instantiate()
	evolution_fx.global_position = player_position
	evolution_fx.z_index = 6 # 잘보이게 앞에두기
	players_parent.add_child(evolution_fx)	
	var subviewport = evolution_fx.get_node("SubViewport")
	var screen_size = DisplayServer.window_get_size()
	# 진화 이펙트 전체화면
	subviewport.size = screen_size
	# 진화 이펙트 배경 투명하게 처리.
	subviewport.transparent_bg = true
	# 렌더링 전 항상 클리어되고 투명 배경을 유지 (다른 이펙트 겹칠때)
	#subviewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	var ani_player = subviewport.get_node("VFX_Level_UP").get_node("AnimationPlayer")
	print("진화 이펙트 시작")
	ani_player.play("evolution")
	await get_tree().create_timer(2).timeout
	print("진화 이펙트 끝")
	evolution_fx.queue_free()

func evolve_player() -> void:
	var origin_player = null
	var children = players_parent.get_children()
	if children.size() > 0:
		origin_player = children[0]
	var players_count = GameManager.player_nums
	
	if players_count==1:
		# 기존 진화 전 플레이어 삭제
		for child in players_parent.get_children():
			if child is Player:
				child.queue_free()
		# 새 플레이어 인스턴스 생성
		var new_player = EVOLVED_PLAYER_SCENE.instantiate()
		# 첫 번쨰 플레이어 위치 복사
		new_player.position = origin_player.position + Vector2(0,-30)
		new_player.z_index = 5
		# 진화 이펙트 실행
		spawn_evolution_effect(new_player.position)
		# 부모 노드(Players)에 새 노드 추가
		players_parent.add_child(new_player)
		new_player.connect("player_arrived", Callable(game, "decide_true_ending"))
		new_player.connect("player_died", Callable(game, "game_over"))
		print("진화 성공!")
	else:
		emit_signal("no_evolution")
		print("진화 실패!")
		
	
