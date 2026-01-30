# script_item_data.gd
extends Resource
class_name ItemData

# 基础道具属性
@export var item_id: String
@export var item_name: String
@export var item_description: String
@export var icon: Texture2D
# 价格费用
@export var unlock_level: int = 1
@export var unlock_exp: int = 100
@export var unlock_credits: int = 100
