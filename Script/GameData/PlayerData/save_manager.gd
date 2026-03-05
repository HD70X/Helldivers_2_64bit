# save_manager.gd (Autoload单例)
extends Node
class_name SaveManagerClass
# 该脚本应该在不同项目中被重新定义具体的储存逻辑，此外其接收储存信号

# 存储地址
const SAVE_DIR = "user://saves/" # 定义存档路径
const SAVE_FILE_PREFIX = "save_" # 定义存档前缀
const SAVE_FILE_EXTENSION = ".cfg" # 定义存档后缀（文件类型）
const DEF_SAVE_PATH = "def_save" # 如果使用默认存档，则会储存到此文件名
const BACK_UP_EXTENSION = ".back" # 如果使用默认存档，则会储存到此文件名
# 自动存储配置
#const AUTO_SAVE_TIME: int = 240
#var auto_save_timer: Timer
#var can_auto_save: bool = true  # 是否允许自动存档

func _ready() -> void:
	# 关连必要信号
	GameEvent.signal_save_def.connect(save_def)
	GameEvent.signal_save_specific.connect(save_specific)
	# 选配定时自动储存，需要配置游戏状态单例配合使用如果不需要则注释
	#auto_save_timer = Timer.new()
	#auto_save_timer.wait_time = AUTO_SAVE_TIME
	#auto_save_timer.timeout.connect(_on_auto_save_timer)
	#add_child(auto_save_timer)
	#auto_save_timer.start()

# 自动存档
#func _on_auto_save_timer():
	#if can_auto_save and not GameState.is_in_combat and not GameState.is_in_dialogue:
		#pass

# 将当前玩家数据储到默认存档
func save_def():
	var _save_path = SAVE_DIR + DEF_SAVE_PATH + SAVE_FILE_EXTENSION
	var _backup_path = SAVE_DIR + DEF_SAVE_PATH + BACK_UP_EXTENSION
	
	var snapshot = PlayerData.to_dict()
	print("数据快照: ", snapshot)
	
	if FileAccess.file_exists(_save_path):
		DirAccess.copy_absolute(_save_path, _backup_path)
	
	GameSave.save_game(snapshot, _save_path)


func load_def() -> Dictionary:
	var _save_path = SAVE_DIR + DEF_SAVE_PATH + SAVE_FILE_EXTENSION
	print("Game loaded: ", _save_path)
	return GameSave.load_game(_save_path)

# 兼容旧命名，后续可移除
func lord_def() -> Dictionary:
	return load_def()

# 将当前数据保存到玩家ID对应的存档
func save_specific():
	var _save_path = SAVE_DIR + SAVE_FILE_PREFIX + str(PlayerData.character_id) + SAVE_FILE_EXTENSION
	var _backup_path = SAVE_DIR + SAVE_FILE_PREFIX + str(PlayerData.character_id) + BACK_UP_EXTENSION
	var snapshot = PlayerData.to_dict()
	if FileAccess.file_exists(_save_path):
		DirAccess.copy_absolute(_save_path, _backup_path)
	GameSave.save_game(snapshot, _save_path)

func load_specific(character_id: int) -> Dictionary:
	var _save_path = SAVE_DIR + SAVE_FILE_PREFIX + str(character_id) + SAVE_FILE_EXTENSION
	return GameSave.load_game(_save_path)

# 兼容旧命名，后续可移除
func lord_specific(character_id: int) -> Dictionary:
	return load_specific(character_id)
