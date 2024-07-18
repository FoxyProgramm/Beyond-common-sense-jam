extends Spatial

var move_in_global_space:bool = true
var dir:Vector3 = Vector3()
var speed:float = 0
var damage:int = 0
var is_died:bool = false

func die():
	if is_died:
		return
	is_died = true
	$col.queue_free()
	var da = create_tween()
	da.tween_property(self, "scale", Vector3(0.01, 0.01, 0.01), 0.3).set_ease(Tween.EASE_IN_OUT)
	da.tween_callback(self, "queue_free")
func _physics_process(delta):
	global_position += dir * speed * delta

func _area_enter(area):
	if area.name == "player_area":
		get_tree().current_scene.pl.take_hit(damage, self)
		die()

func _body_enter(body):
	die()
