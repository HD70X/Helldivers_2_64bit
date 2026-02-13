extends CharacterBody2D

@onready var animation_tree = $AnimationTree
@onready var playback = animation_tree.get("parameters/playback")

# 战术常数
const SPEED = 200.0
const FRICTION = 800.0  # 停止的速度（数值越高，停得越快，越不滑）
const GRAVITY = 980.0   # 超级地球的标准重力
const MAX_SLOPE_ANGLE = deg_to_rad(65) # 标准地形的最大爬坡角度65度，大于此值会滑落


func _physics_process(delta):
	# 1. 应用重力（手动挡）
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	# 2. 获取输入
	var input = Input.get_axis("move_left", "move_right")
	
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

func update_animation_parameters(input):
	animation_tree.set("parameters/conditions/moving_forward", input > 0)
	animation_tree.set("parameters/conditions/moving_reverse", input < 0)
	animation_tree.set("parameters/conditions/not_moving", input == 0)
