extends Button
@onready var game: Node2D = get_node("/root/Game")
@onready var players_parent: Node2D = $"../../../Players"
@onready var evolution_sfx: AudioStreamPlayer = $"../EvolutionSFX"

var evolution_effect = preload("res://scenes/evolution.tscn")
signal no_evolution
signal evolved

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
	
	var ani_player = subviewport.get_node("VFX_Level_UP").get_node("AnimationPlayer")
	ani_player.play("evolution")
	await get_tree().create_timer(2).timeout
	evolution_fx.queue_free()

func evolve_player() -> void:
	var origin_player = null
	var children = players_parent.get_children()
	if children.size() > 0:
		origin_player = children[0]
	var players_count = GameManager.player_nums
	var evolution_state = GameManager.evolution_state
	if GameManager.evolution_state == false and players_count==5:
		# 진화
		GameManager.evolution_state = true
		# 플레이어 1명 남기고 다 삭제
		for child in players_parent.get_children():
			if child is Player and GameManager.player_nums > 1:
				
				var has_camera = false
				for grandchild in child.get_children():
					if grandchild is Camera2D or grandchild is Camera3D:
						has_camera = true
						break
				if has_camera:
					# 1명 남은 플레이어 진화
					spawn_evolution_effect(child.position)
				else:
					child.queue_free()
					GameManager.player_nums -= 1

		# 진화 이펙트 실행
		evolution_sfx.play()
		emit_signal("evolved")
		
	else:
		emit_signal("no_evolution")
