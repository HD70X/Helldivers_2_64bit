# object_pool
extends Node

# 使用字典来管理多种类型的对象池
var pools = {}            # { scene_path: Array[Node] }
var active_objects = {}  # 同样按场景路径分类

# 由 LevelManager 在关卡开始前调用
func prepare_level(config: LevelConfig):
	# 1. 清理上一关的残留（非常重要，防止内存溢出）
	_clear_all_pools()
	# 2. 扫描本关所有需要的 ThrowableData（包含掉落和合成链路）
	var required_items = _scan_required_items(config)
	# 3. 批量创建对象池
	for data in required_items:
		_create_single_pool(data, config)
	print("对象池：关卡资源准备就绪，共初始化了 ", pools.size(), " 个池子")

# 扫描算法：自动追踪合成链
func _scan_required_items(config: LevelConfig) -> Array[ThrowableData]:
	var result: Array[ThrowableData] = []
	var seen = {}
	# 遍历掉落列表
	for start_item in config.drop_weights.keys():
		var curr = start_item
		while curr != null:
			if not seen.has(curr.resource_path):
				result.append(curr)
				seen[curr.resource_path] = true
			# 到达终点或链路断开
			if curr.next_form == null:
				break
			curr = curr.next_form
	return result

# 创建单个对象的池子
func _create_single_pool(data: ThrowableData, config: LevelConfig):
	pools[data.resource_path] = []
	active_objects[data.resource_path] = []
	# 确定池子大小：优先从关卡覆盖配置拿，没有就用默认
	var size = config.pool_overrides.get(data, config.default_pool_size)
	
	for i in range(size):
		var obj = data.scene.instantiate()
		obj.data = data
		_deactivate_object(obj) # 统一重置逻辑
		add_child(obj)
		pools[data.resource_path].append(obj)

# 统一的对象停用逻辑
func _deactivate_object(obj):
	obj.visible = false
	obj.process_mode = Node.PROCESS_MODE_DISABLED
	if obj is RigidBody2D:
		obj.freeze = true
		obj.linear_velocity = Vector2.ZERO
		obj.angular_velocity = 0
		obj.constant_force = Vector2.ZERO
		obj.constant_torque = 0
	if obj.has_method("reset_state"): # 之前建议过的状态清理
		obj.reset_state()

# 清理方法：切换关卡时调用
func _clear_all_pools():
	# 这里的逻辑是直接删除所有子节点
	for child in get_children():
		child.queue_free()
	pools.clear()

func get_object(next_data: ThrowableData):
	var path = next_data.resource_path
	if not pools.has(path):
		push_error("对象池中没有场景: " , path)
		return null
	
	if pools[path].is_empty():
		print("警告：" , path, " 的对象池已空，创建新对象")
		var scene = next_data.scene
		var obj = scene.instantiate()
		if "data" in obj:
			obj.data = next_data
		return obj  # 新对象不需要从对象池移除父节点
	
	var obj = pools[path].pop_back()
	
	# 先从对象池移除
	remove_child(obj)
	
	# 唤醒对象
	obj.visible = true
	obj.process_mode = Node.PROCESS_MODE_INHERIT
	if obj.has_method("set_freeze_enabled"):
		obj.freeze = false
	active_objects[path].append(obj)
	obj.is_merging = false
	return obj

func return_object(obj):
	var path = obj.data.resource_path
	
	if not pools.has(path):
		push_error("尝试归还未知类型的对象")
		return
	
	# 从当前父节点移除
	if obj.get_parent():
		obj.get_parent().remove_child(obj)
	
	# 重置对象状态
	obj.visible = true
	obj.process_mode = Node.PROCESS_MODE_DISABLED
	if obj.has_method("set_freeze_enabled"):
		obj.freeze = true
	obj.position = Vector2.ZERO
	if obj is RigidBody2D:
		obj.linear_velocity = Vector2.ZERO
		obj.angular_velocity = 0
	
	# 重新添加到对象池
	add_child(obj)
	
	active_objects[path].erase(obj)
	pools[path].append(obj)

# 将所有正在场景中运行的对象全部回收
func return_all_active_objects():
	# 我们需要创建一个临时数组来遍历，因为 return_object 会修改 active_objects 字典
	var all_to_return = []
	
	for scene_path in active_objects.keys():
		# 使用 duplicate() 避免在遍历时修改数组导致出错
		var active_list = active_objects[scene_path].duplicate()
		all_to_return.append_array(active_list)
	
	# 逐个调用你已经写好的 return_object 方法
	for obj in all_to_return:
		# 使用 call_deferred 确保在物理安全时回收，防止场景树操作冲突
		call_deferred("return_object", obj)
		
	print("对象池：已回收所有活跃对象，共计: ", all_to_return.size())
