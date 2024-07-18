extends EnemyBase

export var disabled:bool = false
var n_move_to := Vector3()

func _ready():
	if disabled:
		set_physics_process(false)

func enable():
	set_physics_process(true)
	disabled = false

func _physics_process(delta):
	gravity()
	n_move_to = (find_dir_to_player())
	move(n_move_to.normalized())
	look_at(self.global_position + vect, Vector3.UP)
	move_and_slide(vect)
