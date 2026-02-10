extends CharacterBody2D

@onready var animation_tree = $AnimationTree
@onready var playback = animation_tree.get("parameters/playback")

func _ready():
	# 确保启动时 AnimationTree 是激活的
	animation_tree.active = true

func _physics_process(delta):
	var input = Input.get_axis("move_left", "move_right")
	
	# 设置转换条件
	animation_tree.set("parameters/conditions/moving_forward", input > 0)
	animation_tree.set("parameters/conditions/moving_reverse", input < 0)
	animation_tree.set("parameters/conditions/not_moving", input == 0)
	print("输入值: ", input)
	print("条件值: ", input != 0)
	print("AnimationTree中的实际条件: ", animation_tree.get("parameters/conditions/moving_forward"))
	print("当前播放状态: ", playback.get_current_node())
	print("---")
	
	velocity.x = input * 200
	move_and_slide()
