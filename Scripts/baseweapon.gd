extends Spatial

export var base_res:Resource = null
var res:WeaponClass

export(float, 0, 1, 0.02) var str_screen_shake:float = 0.1

func _ready():
	res = base_res.duplicate()

func get_ammo():
	res.ammo = clamp(res.ammo + res.get_ammo_per_box, 0, res.max_ammo)

func wait_shoot_period():
	res.pass_shoot_period = false
	yield(get_tree().create_timer(res.shoot_period), "timeout")
	res.pass_shoot_period = true

func can_shoot():
	if res.endless_ammo:
		if res.pass_shoot_period:
			wait_shoot_period()
			return true
	elif res.ammo > 0 and res.pass_shoot_period:
		res.ammo -= 1
		wait_shoot_period()
		return true
	return false
