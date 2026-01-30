# item_unstackable_instance.gd
extends Resource
class_name ItemUnstackableInstance

# 实例唯一ID
@export var instance_id: String
# 原始数据模板
@export var template_id: String
@export var equiped: bool

# 动态属性
#var durability: float
#var max_durability: float
#var enhancement_level: int = 0

func _init(_template_id: String = ""):
	if _template_id != "":
		self.template_id = _template_id
		self.instance_id = _generate_unique_id()
		self.equiped = false

func _generate_unique_id() -> String:
	return template_id + "_" + str(ResourceUID.create_id())

func to_dict() -> Dictionary:
	return{
		"instance_id": instance_id,
		"template_id": template_id,
		"equiped": equiped
	}

static func from_dict(data: Dictionary) -> ItemUnstackableInstance:
	var item_instance = ItemUnstackableInstance.new()
	item_instance.instance_id = data["instance_id"]
	item_instance.template_id = data["template_id"]
	item_instance.equiped = data.get("equiped", false)
	return item_instance
