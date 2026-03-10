extends CharacterBody2D

@export var weapon_path: NodePath = ^"Skeleton2D/Bone2D/Bone2DBody/Bone2DArmR/Bone2DWeapon/Weapon"

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback = animation_tree.get("parameters/playback")
@onready var weapon: Node = get_node_or_null(weapon_path)

# 战术常数
const SPEED = 200.0
const FRICTION = 800.0  # 停止的速度（数值越高，停得越快，越不滑）
const GRAVITY = 980.0   # 超级地球的标准重力
const MAX_SLOPE_ANGLE = deg_to_rad(65) # 标准地形的最大爬坡角度65度，大于此值会滑落
const MOVE_LEFT_ACTION := "move_left"
const MOVE_RIGHT_ACTION := "move_right"
const FIRE_ACTION := "fire"
const RELOAD_ACTION := "reload"

func _ready() -> void:
	if weapon == null:
		weapon = find_child("Weapon", true, false)
	if weapon and weapon.has_signal("bullet_fired"):
		var bullet_callable := Callable(self, "_on_weapon_bullet_fired")
		if not weapon.is_connected("bullet_fired", bullet_callable):
			weapon.connect("bullet_fired", bullet_callable)

func _physics_process(delta):
	# 1. 应用重力（手动挡）
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	# 2. 获取输入
	var input = Input.get_axis(MOVE_LEFT_ACTION, MOVE_RIGHT_ACTION)
	
	# 3. 处理移动与摩擦力
	if input != 0:
		# 加速移动
		velocity.x = input * SPEED
	else:
		# 应用摩擦力（让角色平滑减速，而不是瞬间定住）
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	
	# 4. 斜坡逻辑
	# floor_max_angle 告诉 Godot 多陡的坡算“地面”
	floor_max_angle = MAX_SLOPE_ANGLE
	
	# 5. 执行移动
	# 这个函数是 Godot 的黑科技，它会自动处理所有的碰撞计算！
	move_and_slide()
	
	# 更新你的动画树参数
	update_animation_parameters(input)
	_handle_combat_input()

func update_animation_parameters(input):
	animation_tree.set("parameters/conditions/moving_forward", input > 0)
	animation_tree.set("parameters/conditions/moving_reverse", input < 0)
	animation_tree.set("parameters/conditions/not_moving", input == 0)

func _handle_combat_input() -> void:
	if weapon == null:
		return
	var should_try_fire := false
	if InputMap.has_action(FIRE_ACTION):
		if _is_weapon_full_auto():
			should_try_fire = Input.is_action_pressed(FIRE_ACTION)
		else:
			should_try_fire = Input.is_action_just_pressed(FIRE_ACTION)
	if should_try_fire:
		var fire_dir := _get_weapon_forward_direction()
		if weapon.has_method("try_fire"):
			weapon.try_fire(fire_dir)
	if InputMap.has_action(RELOAD_ACTION) and Input.is_action_just_pressed(RELOAD_ACTION):
		if weapon.has_method("start_reload"):
			weapon.start_reload()

func _get_weapon_forward_direction() -> Vector2:
	if weapon is Node2D:
		var dir := (weapon as Node2D).global_transform.x.normalized()
		if dir != Vector2.ZERO:
			return dir
	return Vector2.RIGHT

func _on_weapon_bullet_fired(pos: Vector2, dir: Vector2, speed: float) -> void:
	if weapon == null or not weapon.has_method("get_bullet_scene"):
		return
	var projectile_scene: PackedScene = weapon.get_bullet_scene()
	if projectile_scene == null:
		return
	var projectile := projectile_scene.instantiate()
	var combat_scene: Node = get_tree().current_scene
	if combat_scene == null:
		combat_scene = get_tree().root
	combat_scene.add_child(projectile)
	if projectile is Node2D:
		var projectile_node := projectile as Node2D
		projectile_node.global_position = pos
		projectile_node.rotation = dir.angle()
	if _has_property(projectile, "direction"):
		projectile.set("direction", dir.normalized())
	if _has_property(projectile, "speed"):
		projectile.set("speed", speed)

func _has_property(target: Object, property_name: StringName) -> bool:
	for prop in target.get_property_list():
		if prop.get("name") == property_name:
			return true
	return false

func _is_weapon_full_auto() -> bool:
	if weapon == null:
		return true
	if _has_property(weapon, "is_full_auto"):
		return bool(weapon.get("is_full_auto"))
	return true
