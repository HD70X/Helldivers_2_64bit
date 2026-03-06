extends Area2D
class_name ProjectileBase

signal hit(target: Node)

@export var speed: float = 1200.0
@export var damage: float = 10.0
@export var life_time: float = 3.0

var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	await get_tree().create_timer(life_time).timeout
	if is_inside_tree():
		queue_free()

func _physics_process(delta: float) -> void:
	global_position += direction.normalized() * speed * delta

func _on_body_entered(body: Node) -> void:
	if body.has_method("apply_damage"):
		body.apply_damage(damage)
	hit.emit(body)
	queue_free()
