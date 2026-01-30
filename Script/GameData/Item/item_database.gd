# item_database.gd
extends Node

var library: ItemLibrary = preload("res://Resources/ItemLibrary/item_library_items.tres")
var items: Dictionary = {}

func _ready() -> void:
	if library:
		items = library.items
	else:
		push_error("ItemDatabase: 无法预加载总表资源！")

func get_item(item_id: String) -> ItemData:
	if items.has(item_id):
		return load(items[item_id][0]) as ItemData
	push_error("未找到道具: " + item_id)
	return null

# 可选:获取所有道具列表
func get_all_items() -> Array:
	return items.keys()
	
# 可选:按类型筛选道具
func get_items_by_type(item_type: String) -> Array:
	var filtered = []
	for id in items:
		if items[id][1] == item_type:
			filtered.append(id)
	return filtered
