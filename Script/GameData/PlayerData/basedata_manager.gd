extends Node
class_name BaseDataManager

# 基础数据组
var system_id: String = "empty"
var character_id: int = 0
var stars: int = 0

func to_dict() -> Dictionary:
	return {"system_id" : system_id, "character_id" : character_id, "stars" : stars}

func from_dict(_data: Dictionary):
	system_id = _data.get("system_id", "empty")
	character_id = _data.get("character_id", 0)
	stars = _data.get("stars", 0)
