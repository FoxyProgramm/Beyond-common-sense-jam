extends KinematicBody
class_name Player_3D_FP

#Simple variables
var vect := Vector3()
var cam_rotation_to := Vector3()
var cam_otdacha := Vector3()
var current_cam_rotation := Vector3()
var cam_rotation_offset := Vector3() 
var cam_jump_offset := Vector3() #<-----  NOT USED YET
var const_sentetive:float = 0.005
var sentetive:float
var cam_walk_shake_sin:float = 0.0
var jump_threhold:int = 0
var speed:float = 0
var acceleration:float = 0

var first_on_ground:bool = false
var jump_tween:bool = false

export var walk_speed:float = 8.0
export var walk_acceleration:float = 1.0
export var can_run:bool = false
export var run_speed:float = 12.0
export var run_acceleration:float = 1.5
export var enable_air_acceleration:bool = true
export var air_acceleration:float = 0.5
export var gravity:float = 10.0
export var gravity_step:float = 1.0
export var jump_str:float = 12.0

export(float, 0.1, 3.0, 0.1) var mouse_sentetive:float = 1.0
export var smooth_mouse:bool = false
export(float, 0.05, 1.0, 0.05) var smooth_speed:float = 1.0

export var cam_limit:Vector2 = Vector2(-PI/2, PI/2)
export var cam_walk_shake:bool = false
export var cam_walk_shake_dir:Vector3 = Vector3()
export(float, 0, 3, 0.1) var cam_walk_shake_str:float = 1.0
export(float, 0, 5, 0.1) var cam_walk_shake_speed:float = 1.0
export(float, 0, 5, 0.1) var cam_run_shake_speed:float = 1.0

export(float, 0, 3, 0.1) var cam_jump_str:float = 1.0

export(float, 0, 1, 0.01) var str_otdacha:float = 0.4

onready var cam = get_node("camera")
onready var jump_ray = get_node("jump_ray")
#onready var interaction_ray = get_node("camera/interaction_ray")

func v2tov3(v:Vector2) -> Vector3:
	return Vector3(v.x, 0, v.y)

func v3tov2(v:Vector3) -> Vector2:
	return Vector2(v.x, v.z)

func _ready():
	speed = walk_speed
	acceleration = walk_acceleration
	find_sentetive()
	current_cam_rotation = cam.rotation

func find_sentetive() -> void:
	sentetive = const_sentetive * mouse_sentetive

func gravity() -> void:
	if is_on_floor():
		if jump_threhold > 0:
			jump_threhold -= 1
		else :
			vect.y = -0.2
			if first_on_ground:
				var da = create_tween()
#				da.tween_property(self, "cam_jump_offset", Vector3(-0.2, 0, 0), 0.2).set_ease(Tween.EASE_OUT_IN)
				da.tween_property(self, "cam_jump_offset", Vector3(0, 0, 0), 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
				first_on_ground = false
	else :
		first_on_ground = true
		vect.y = move_toward(vect.y, -gravity, gravity_step)
		if !jump_tween:
			cam_jump_offset = cam_jump_offset.move_toward(Vector3(vect.y/gravity*cam_jump_str, 0, 0), 0.005)

func is_run():
	return Input.is_action_pressed("run")

func check_jump() -> void:
	if Input.is_action_just_pressed("jump"):
		if jump_ray.is_colliding():
			vect.y = jump_str
			jump_threhold = 4
			
#			jump_tween = true
#			var da = create_tween()
#			da.tween_property(self, "cam_jump_offset", Vector3(-0.05, 0, 0), 0.1).set_ease(Tween.EASE_IN_OUT)
#			da.tween_property(self, "jump_tween", false, 0)
			
func find_move_dir() -> Vector3:
	return (cam.transform.basis * v2tov3(Input.get_vector("left", "right", "up", "down")) * Vector3(1, 0, 1)).normalized()

func move(v:Vector3) -> void:
	var new_v:Vector3 = vect
	if can_run:
		if is_run():
			speed = run_speed
			acceleration = run_acceleration
		else :
			speed = walk_speed
			acceleration = walk_acceleration
	if air_acceleration:
		if is_on_floor():
			new_v = new_v.move_toward(v*speed, acceleration)
		else :
			new_v = new_v.move_toward(v*speed, air_acceleration)
	else :
		new_v = new_v.move_toward(v*speed, acceleration)
	vect.x = new_v.x
	vect.z = new_v.z
	
func slide() -> void:
	move_and_slide(vect, Vector3.UP)
	if is_on_ceiling():
		vect.y = -0.2

func _process(delta):
	if cam_walk_shake:
		if v3tov2(vect):
			if can_run and is_run():
				cam_walk_shake_sin += 0.1 * cam_run_shake_speed
			else :
				cam_walk_shake_sin += 0.1 * cam_walk_shake_speed
			cam_rotation_offset = cam_walk_shake_dir * cam_walk_shake_str * sin(cam_walk_shake_sin)
			if cam_walk_shake_sin > 6.3:
				cam_walk_shake_sin -= 6.3
		else :
			var target = int(cam_walk_shake_sin > 3.14) * 6.28
			cam_walk_shake_sin = move_toward(cam_walk_shake_sin, target, 0.03*cam_walk_shake_speed)
			cam_rotation_offset = cam_walk_shake_dir * cam_walk_shake_str * sin(cam_walk_shake_sin)
	if smooth_mouse:
		current_cam_rotation += (cam_rotation_to-current_cam_rotation) * smooth_speed * delta * 60
		cam.rotation = current_cam_rotation+cam_rotation_offset+cam_jump_offset+(cam_otdacha * str_otdacha)
		cam_otdacha = cam_otdacha.move_toward(Vector3(0, 0, 0), 0.3*delta)
#		cam_otdacha = cam_otdacha.cubic_interpolate()

func _input(event):
	if event is InputEventMouseMotion:
		if smooth_mouse:
			cam_rotation_to.y -= event.relative.x * sentetive
			cam_rotation_to.x = clamp(cam_rotation_to.x - event.relative.y * sentetive, cam_limit.x, cam_limit.y)
		else :
			cam.rotation.y -= event.relative.x * sentetive
			cam.rotation.x = clamp(cam.rotation.x - event.relative.y * sentetive, cam_limit.x, cam_limit.y)
	if event.is_action_pressed("quit"):
		get_tree().quit()
