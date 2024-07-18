extends KinematicBody
class_name EnemyBase

signal player_near
signal im_die

var vect := Vector3()
var move_to := Vector3()
var is_attack:bool = false

export var name_enemy = ''
export var max_hp:int = 100
export var damage:int = 10
export var period_attack:float = 3.0
export var period_attack_spread:float = 1.0
export var speed:float = 6.0
export var acceleration:float = 1.0
export var chance_to_drop_box:float = 0.15

onready var hp := max_hp
onready var player = get_tree().current_scene.pl
onready var die_particle = get_tree().current_scene.get_node('die_particle')
onready var stuff = get_tree().current_scene.get_node('stuff')


func _ready():
	get_node("ch_pl_dist").connect("timeout", self, "_go_to_player")

func _go_to_player():
	pass

func get_player_ammos() -> float:
	var i:float = 0.0
	var output = 0
	for weapon in player.weapons:
		if not weapon.res.endless_ammo:
			output += (weapon.res.ammo / float(weapon.res.max_ammo))
			i += 1.0
	return output / i

func find_dir_to_player() -> Vector3:
	return player.global_position - self.global_position

func die():
	emit_signal("im_die")
	if randf() < chance_to_drop_box * ((1-get_player_ammos())+1):
		get_tree().current_scene.create_box(self.global_position)
	var new_particle = die_particle.duplicate()
	new_particle.delete_on_end = true
	new_particle.position = self.global_position
	stuff.add_child(new_particle)
	self.queue_free()

func take_hit(value):
	hp -= value
	if hp <= 0:
		die()

func attack():
	is_attack = true
	vect = Vector3()
	look_at((self.global_position + find_dir_to_player()) * Vector3(1,0,1)+Vector3(0, self.global_position.y, 0), Vector3.UP)
	get_node('anim').play('attack')
	yield(get_node("anim"), "animation_finished")
	is_attack = false

func gravity():
	vect.y = move_toward(vect.y, -10, 0.4)

func move(to:Vector3):
	var new_vect = vect
	new_vect = new_vect.move_toward(to*speed, acceleration)
	vect.x = new_vect.x
	vect.z = new_vect.z
