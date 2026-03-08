extends Area2D
class_name ProjectileBase

signal hit(target: Node)

@export var speed: float = 1200.0
@export var damage: float = 10.0
@export var life_time: float = 3.0

var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	body_entered.connect(_on_any_hit)
	area_entered.connect(_on_any_hit)
	await get_tree().create_timer(life_time).timeout
	if is_inside_tree():
		queue_free()

func _physics_process(delta: float) -> void:
	global_position += direction.normalized() * speed * delta

func _on_any_hit(target: Node) -> void:
	if target.has_method("apply_damage"):
		target.apply_damage(damage)
	hit.emit(target)
	queue_free()
