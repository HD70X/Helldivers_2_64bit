# item_stackable.gd
extends ItemData
class_name ItemStackable

enum ItemType {
	ITEM
}

# 基础道具属性
@export var item_Type: ItemType
@export var stack: int = 0
@export var max_stack: int = 99  # 最大堆叠数量
