extends Spatial
class_name Billboard

export var target_path:NodePath
onready var target = get_node(target_path)

func _process(delta):
	look_at(target.global_position, Vector3.UP)
