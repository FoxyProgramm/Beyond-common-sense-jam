extends EnemyBase

export var disabled:bool = false
var n_move_to := Vector3()

func _go_to_player():
	if is_attack:
		return
	n_move_to = (find_dir_to_player())
	if n_move_to.length() < 4:
		attack()

func _ready():
	if disabled:
		set_physics_process(false)
	else :
		$ch_pl_dist.start()
func enable():
	set_physics_process(true)
	disabled = false
	$ch_pl_dist.start()

func _physics_process(delta):
	gravity()
	if not is_attack:
		move(n_move_to.normalized())
		move_and_slide(vect, Vector3.UP)
