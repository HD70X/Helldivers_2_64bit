extends Node
class_name NetworkSyncBridge

# 仅作为网络层桥接占位：
# - 输入快照采集
# - 状态回放/插值
# 不直接包含角色核心玩法逻辑。

func collect_input_snapshot() -> Dictionary:
	return {}

func apply_remote_state(_state: Dictionary) -> void:
	pass
