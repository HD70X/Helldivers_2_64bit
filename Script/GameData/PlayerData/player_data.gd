# player_data.gd (Autoload 单例)
extends Node
# 该脚本是游戏运行期间的玩家数据单例，该单例因该避免直接修改BasePlayerData的字典数据，应该尽可能将数据还原为运行时需要读取的格式和实例，储存时再将其压缩为字典

# 基础数据组
var system_id: String
var character_id: int
var stars: int

# 复杂数据组
var inventory: InventoryManager
var progression: ProgressionManager

func _ready() -> void:
	# 基础数据默认值
	system_id = "NoPlayerData"
	character_id = 0
	stars = 0
	# 必须手动实例化类，否则它们是 null
	inventory = InventoryManager.new()
	progression = ProgressionManager.new()
	from_dict(SaveManager.lord_def())

## 初始化一个全新的玩家数据（用于新游戏）
func init_new_player() -> void:
	# 基础数据
	system_id = OS.get_unique_id()
	character_id = ResourceUID.create_id()
	stars = 0
	# 复杂数据
	inventory = InventoryManager.new()
	progression = ProgressionManager.new()

## 序列化
# 将数据拍扁成 ConfigFile 能理解的纯字典
func to_dict() -> Dictionary:
	var player_data = {}
	# 基础数据处理
	player_data["base_data"] = {
		"system_id" : system_id,
		"character_id" : character_id,
		"stars" : stars
	}
	# 复杂数据处理
	player_data["inventory"] = inventory.to_dict()
	player_data["progression"] = progression.to_dict()
	return player_data

## 反序列化
func from_dict(player_data: Dictionary):
	if player_data == {}:
		init_new_player()
	else:
		# 基础数据处理
		system_id = player_data.get("base_data").get("system_id")
		character_id = player_data.get("base_data").get("character_id")
		stars = player_data.get("base_data").get("stars")
		# 复杂数据处理
		inventory.from_dict(player_data.get("inventory"))
		progression.from_dict(player_data.get("progression"))
