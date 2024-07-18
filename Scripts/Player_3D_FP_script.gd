extends Player_3D_FP

var method = "movement"
var hp:int = 100
var died:bool = false
onready var num = preload("res://Scenes/num.tscn")
onready var stuff := $"../stuff"

export var dash:String = "dash"
export var can_dash:bool = false
export var dash_strength:float = 15
export var dash_duration:float = 0.3
export var dash_reload:float = 0.4
export var damage:int = 10

export var frames_invincible:int = 15
var fi:int = 0

onready var weapons = [$camera/weapons/Revolver, $camera/weapons/Riffle, $camera/weapons/Sniperka]
onready var cur_weapon = $camera/weapons/Revolver
var cur_id_weapon = 0
var dash_vect:Vector3 = Vector3.ZERO
var is_dash:bool = false

func _ready():
	$"../room_final/final".connect("area_entered", self, "win")
	if GameST.one_hp:
		hp = 1
		$"../GUI/death_msg/one_hp".show()
	$"../GUI/control/hp".value = 0
	$dash_duration.connect("timeout", self, "end_dash")
	$dash_reload.connect("timeout", self, "enable_dash")
	$dash_duration.wait_time = dash_duration
	$dash_reload.wait_time = dash_reload
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	yield(get_tree().create_timer(2), "timeout")
	show_ammo()
	show_hp(1)

func round_with(v:float, ampl:int):
	return round(v * pow(10, ampl))

func transform_time(time:float) -> String:
	var minutes = int(time/60.0)
	var seconds = int(time) - (60*minutes)
	var miliseconds = round_with(time - int(time), 3)
	return ("%02d:%02d:%03d" % [minutes, seconds, miliseconds])

func win(area):
	if area.name != "player_area":
		return
	$"..".set_physics_process(false)
	set_physics_process(false)
	died = true
	GameST.stoplist()
	var da = create_tween()
	set_process_input(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if OS.get_name() != "HTML5":
		if GameST.one_hp:
			var medal = preload("res://materials/BCS_2.png")
			medal.get_data().save_png("Медалька за полную потерю вообще любого рассудка.png")
		else :
			var medal = preload("res://materials/BCS_1.png")
			medal.get_data().save_png("Медалька за потерю здравого рассудка.png")
	$"../GUI/win_msg".show()
	da.tween_property($"../GUI/win_msg", "modulate", Color(1,1,1,1), 0.3)
	yield(get_tree().create_timer(1), "timeout")
	$"../GUI/win_msg/anim".play("win_msg")
	yield($"../GUI/win_msg/anim", "animation_finished")
	$"../GUI/win_msg/ScrollContainer/VBoxContainer/Label".text += "\n\nПрожитое Время:"+ str(transform_time($"..".cur_time)) +"\nКол-во зачищеных комнат:100"
	
func die():
	died = true
	set_physics_process(false)
	GameST.stoplist()
	var da = create_tween()
	set_process_input(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$"..".set_physics_process(false)
	$"../GUI/death_msg".show()
	$"../GUI/death_msg/Label2/Label".text = transform_time($"..".cur_time)
	$"../GUI/death_msg/Label3/Label".text = str($"..".cur_room_id-2)
	da.tween_property($"../GUI/death_msg", "modulate", Color(1, 1, 1, 1), 0.3)
	da.tween_callback($"../GUI/death_msg/anim", "play", ["death_msg"])
#	get_tree().paused = true

func dash():
	move(dash_vect)
	slide()

func start_dash():
	is_dash = true
	dash_vect = find_move_dir() * dash_strength
	vect = dash_vect
	method = "dash"
	$dash_duration.start()
	$dash.play()
	
func end_dash():
	$dash_duration.stop()
	$dash_reload.start()
	method = "movement"

func enable_dash():
	is_dash = false

func movement():
	gravity()
	check_jump()
	move(find_move_dir())
	if vect.x and vect.z and is_on_floor():
		$footsteps.volume_db = linear2db(1)
	else :
		$footsteps.volume_db = linear2db(0)
		
	if can_dash:
		if Input.is_action_just_pressed(dash) and not is_dash and find_move_dir():
			start_dash()
	slide()

func show_hp(fade:float = 0.3):
	create_tween().tween_property($"../GUI/control/hp", "value", hp, fade)

func take_hit(value, node):
	if fi > 0:
		return
	hp -= value
	if hp <= 0:
		die()
	fi = frames_invincible
	if node:
		vect = (self.global_position - node.global_position).normalized() * 30
	var da = create_tween()
	da.tween_property($"../GUI/control/vignette", "modulate", Color(1, 1, 1, 1), 0.3)
	da.tween_property($"../GUI/control/vignette", "modulate", Color(1, 1, 1, 0), 0.8)
	show_hp()

func show_ammo():
	if cur_weapon.res.endless_ammo:
		$"../GUI/control/ammos/Label".text = "infinity"
	else:
		$"../GUI/control/ammos/Label".text = str(cur_weapon.res.ammo) + "/" + str(cur_weapon.res.max_ammo)

func ch_weapon_to(pos:int, set_id:bool = false):
	if pos <= weapons.size()-1:
		if set_id:
			cur_id_weapon = pos
		cur_weapon.hide()
		cur_weapon = weapons[pos]
		show_ammo()
		cur_weapon.show()

func shoot():
	if Input.is_action_pressed("fire"):
		if not cur_weapon.can_shoot():
			return
		if $camera/fire_ray.is_colliding():
			var point_pos = $camera/fire_ray.get_collision_point()
			var collider = $camera/fire_ray.get_collider()
			if collider.name == "enemy_area":
				damage = cur_weapon.res.damage + rand_range(-cur_weapon.res.damage_spread, cur_weapon.res.damage_spread)
				collider.get_parent().take_hit(damage)
				create_num(point_pos.move_toward(self.global_position, 0.5))
			else :
				var new_gp = $"../ground_particle".duplicate()
				new_gp.position = point_pos
				new_gp.delete_on_end = true
				stuff.add_child(new_gp)
				new_gp.look_at($camera/fire_ray.get_collision_normal(), Vector3.UP)
		cur_weapon.get_node("anim").stop()
		cur_weapon.get_node("anim").play("shoot", -1, 1, false)
		show_ammo()
		cur_weapon.get_node("shot_sound").play()
		cam_otdacha = cur_weapon.str_screen_shake * Vector3(0.5, 0, 0.1)

func pick_weapon():
	pass

func _physics_process(delta):
	call(method)
	shoot()
	if fi > 0:
		fi -= 1

func create_num(pos:Vector3):
	var new_num = num.instance()
	new_num.target_path = self.get_path()
	new_num.position = pos
	new_num.get_node("Label3D").text = str(damage)
	stuff.add_child(new_num)
	new_num.get_node("anim").play("fade")
	yield(new_num.get_node("anim"), "animation_finished")
	new_num.queue_free()

func _input(event:InputEvent):
	if event.is_action_pressed("quit"):
		get_tree().quit()
	if event.is_action_pressed("fire"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("weapon_1"):
		ch_weapon_to(0, true)
	elif event.is_action_pressed("weapon_2"):
		ch_weapon_to(1, true)
	elif event.is_action_pressed("weapon_3"):
		ch_weapon_to(2, true)
	if event.is_action_pressed("weapon_down"):
		cur_id_weapon -= 1
		if cur_id_weapon < 0:
			cur_id_weapon = weapons.size()-1
		ch_weapon_to(cur_id_weapon)
	elif event.is_action_pressed("weapon_up"):
		cur_id_weapon += 1
		if cur_id_weapon == weapons.size():
			cur_id_weapon = 0
		ch_weapon_to(cur_id_weapon)
	elif event.is_action_pressed("make_weapon_infinity"):
		cur_weapon.res.endless_ammo = !cur_weapon.res.endless_ammo
		show_ammo()
	if event.is_action_pressed("force_die"):
		die()
	elif event.is_action_pressed("debug"):
		Input.mouse_mode = abs(Input.mouse_mode - 2)
func _area_enter(area):
	var groups = area.get_groups()
	if "bobo" in groups:
		var area_parent = area.get_parent()
		if area_parent is EnemyBase:
			if area_parent.name_enemy == "wheel":
				if (area_parent.vect * Vector3(1,0,1)).length() > 9:
					take_hit(area_parent.damage, area_parent)
			else :
				take_hit(area_parent.damage, area_parent)
		else :
			take_hit(10, null)
	if "ammos" in groups:
		area.queue_free()
		$get_ammo.play()
		for weapon in weapons:
			weapon.get_ammo()
		show_ammo()
