extends EnemyBase

var bullet = preload("res://Scenes/bullet.tscn")
export var bullet_speed:float = 3

var move_to_2:Vector3 = Vector3()

func _ready():
	set_physics_process(false)
	$shoot_time.connect("timeout", self, "shoot")

func _go_to_player():
	var direction := find_dir_to_player()
	if direction.length() < 8:
		move_to_2 = -direction.normalized()
	elif direction.length() > 12:
		move_to_2 = direction.normalized()
	else :
		move_to_2 = Vector3(0,0,0)

func shoot():
	$shoot_time.wait_time = period_attack + rand_range(-period_attack_spread, period_attack_spread)
	var new_bullet = bullet.instance()
	new_bullet.position = $pos.global_position
	new_bullet.dir = find_dir_to_player().normalized()
	new_bullet.speed = bullet_speed
	new_bullet.damage = damage
	stuff.add_child(new_bullet)

func enable():
	set_physics_process(true)
	$shoot_time.start()
	$ch_pl_dist.start()

func _physics_process(delta):
	move(move_to_2)
	look_at(player.global_position, Vector3.UP)
	move_and_slide(vect)
