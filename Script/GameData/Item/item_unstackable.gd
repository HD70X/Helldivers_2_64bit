# item_unstackable.gd
extends ItemData
class_name ItemUnstackable

enum ItemType {
	WEAPON,
	BRIDGE,
	HULL,
	ENGINE
}

# 基础道具属性
@export var item_Type: ItemType
# 实例化场景地址
@export var scene_path: PackedScene
# 武器专属属性
@export var damage: float = 0
@export var cooldown: float = 0
@export var damagerange: float = 0
# 舰桥专用属性
@export var unlocked_weapon_slots: Array = [false,false,false]
# 引擎专用属性
@export var speed_bonus: float = 0
# 船体专用属性
@export var health_bonus: float = 0

# 创建一个新的实例装备
func create_instance() ->ItemUnstackableInstance:
	return ItemUnstackableInstance.new(item_id)
