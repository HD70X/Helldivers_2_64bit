# inventory_manager.gd
extends Node
class_name InventoryManager

var stackable_items: Dictionary = {}
var unstackable_instances: Array = []

# 添加物品
func add_item(item_id: String, quantity: int) -> Array:
	var created_ids = []
	var item_data = ItemDatabase.get_item(item_id)
	
	if item_data is ItemStackable:
		stackable_items[item_id] = stackable_items.get(item_id, 0) + quantity
	elif item_data is ItemUnstackable:
		for i in quantity:
			var instance = item_data.create_instance()
			unstackable_instances.append(instance)
			created_ids.append(instance.instance_id)
	return created_ids

# 查找实例
func find_instance(instance_id: String) -> ItemUnstackableInstance:
	for item in unstackable_instances:
		if item.instance_id == instance_id:
			return item
	return null

# 序列化方法
func to_dict() -> Dictionary:
	var data_stackable_items = stackable_items.duplicate(true)
	var data_unstackable_instances = unstackable_instances
	var data = {
		"stackable_items" : data_stackable_items,
		"unstackable_instances" : {}
	}
	for item in data_unstackable_instances:
		if item.has_method("to_dict"):
			data["unstackable_instances"][item.instance_id] = item.to_dict()
	return data

# 反序列化
func from_dict(data: Dictionary):
	stackable_items = {}
	unstackable_instances = []
	stackable_items = data.get("stackable_items", {})
	var temp_unstackable_instances = data.get("unstackable_instances", {})
	for item in temp_unstackable_instances.values():
		unstackable_instances.append(ItemUnstackableInstance.from_dict(item))
