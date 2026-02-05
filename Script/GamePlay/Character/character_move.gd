extends CharacterBody2D

# 移动参数
const SPEED = 200.0
const JUMP_VELOCITY = -400.0

# 重力（使用项目设置中的默认重力）
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# 添加重力
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# 处理跳跃
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# 获取输入方向：-1（左）、0（无）、1（右）
	var direction = Input.get_axis("ui_left", "ui_right")
	
	# 应用水平移动
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# 移动角色
	move_and_slide()
