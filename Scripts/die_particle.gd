extends CPUParticles

export var delete_on_end:bool = true

func _ready():
	if delete_on_end:
		emitting = true
		yield(get_tree().create_timer(2), "timeout")
		self.queue_free()
