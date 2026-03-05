extends Node
class_name PlayerEquipmentModule

@export var active_weapon_path: NodePath
@onready var active_weapon = get_node_or_null(active_weapon_path)

func try_fire(dir: Vector2) -> void:
	if active_weapon and active_weapon.has_method("try_fire"):
		active_weapon.try_fire(dir)

func start_reload() -> void:
	if active_weapon and active_weapon.has_method("start_reload"):
		active_weapon.start_reload()
