extends Node
class_name PlayerHealthModule

signal hp_changed(current_hp: float, max_hp: float)
signal died

@export var max_hp: float = 100.0
var current_hp: float

func _ready() -> void:
	current_hp = max_hp
	hp_changed.emit(current_hp, max_hp)

func apply_damage(amount: float) -> void:
	if amount <= 0.0:
		return
	current_hp = max(0.0, current_hp - amount)
	hp_changed.emit(current_hp, max_hp)
	if current_hp <= 0.0:
		died.emit()

func heal(amount: float) -> void:
	if amount <= 0.0:
		return
	current_hp = min(max_hp, current_hp + amount)
	hp_changed.emit(current_hp, max_hp)
