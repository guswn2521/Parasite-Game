extends Button

@onready var duplication_sfx: AudioStreamPlayer = $"../DuplicationSFX"
@onready var players_parent: Node2D = $"../../../Players"
var PLAYER_SCENE = preload("res://scenes/player.tscn")
var duplicate_effect = preload("res://scenes/duplicate_effect.tscn")
signal no_duplication

func _ready() -> void:
	# 포커스 받으면, 엔터, 스페이스바 눌러도 눌려서, 포커스 안받게
	self.focus_mode = Control.FOCUS_NONE
	self.pressed.connect(duplicate_player)

func spawn_duplicate_effect(player_position:Vector2) -> void:
	var duplicate_fx = duplicate_effect.instantiate()
	duplicate_fx.global_position = player_position
	duplicate_fx.lifetime = 0.25
	duplicate_fx.z_index = 6
	players_parent.add_child(duplicate_fx)
	print("복제 이펙트 시작")
	duplicate_fx.emitting = true
	await get_tree().create_timer(0.5).timeout
	print("복제 이펙트 끝")
	duplicate_fx.queue_free()

func duplicate_player() -> void:
	var origin_player = null
	var children = players_parent.get_children()
	var players_count = GameManager.player_nums
	
	print("복제 전 모체 수 :",players_count)
	if children.size() > 0:
		origin_player = children[0]
	else:
		print("No origin player!")
		return
	
	if GameManager.evolution_state == false and GameManager.dna > 0 and players_count <= 4:
		GameManager.use_item()
		# 새 플레이어 인스턴스 생성
		var new_player = PLAYER_SCENE.instantiate()
		# 첫 번쨰 플레이어 위치 복사
		new_player.position = origin_player.position + Vector2(0,-30)
		new_player.z_index = 5
		# 복제 이펙트 실행
		spawn_duplicate_effect(new_player.position + Vector2(-13,-20))
		await get_tree().create_timer(0.3).timeout
		# 부모 노드(Players)에 새 노드 추가
		players_parent.add_child(new_player)
		duplication_sfx.play()
		print("복제 성공! 모체 수: ",GameManager.player_nums)
	else:
		emit_signal("no_duplication")
		print("dna 가 부족하거나, 최대 복제 수 5에 도달 or 진화했습니다.")
		
	
