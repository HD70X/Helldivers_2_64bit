extends CharacterBody2D
class_name PlayerCharacter

@export var movement_path: NodePath
@export var health_path: NodePath
@export var equipment_path: NodePath

@onready var movement_module = get_node_or_null(movement_path)
@onready var health_module = get_node_or_null(health_path)
@onready var equipment_module = get_node_or_null(equipment_path)

func _physics_process(delta: float) -> void:
	if movement_module and movement_module.has_method("tick_physics"):
		movement_module.tick_physics(self, delta)

func apply_damage(amount: float) -> void:
	if health_module and health_module.has_method("apply_damage"):
		health_module.apply_damage(amount)

func try_fire(dir: Vector2) -> void:
	if equipment_module and equipment_module.has_method("try_fire"):
		equipment_module.try_fire(dir)
