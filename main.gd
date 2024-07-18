extends Spatial

onready var pl = $player
onready var gui = $GUI
onready var show_credits = $GUI/control/song_titles/show_credits

var box = preload("res://Scenes/box.tscn")

var cur_room_id:int = 1
var cur_time:float = 0

func round_with(v:float, trail:int) -> float:
	return round( v * pow(10, trail) ) / float(pow(10, trail))

func _physics_process(delta):
	cur_time += 1.0/60.0
	$GUI/control/time.text = "time: " + str(round_with(cur_time, 1))
#	$walls.material_override.set("uv1_offset", Vector3(0, cur_time*0.1, 0))
func _ready():
	set_physics_process(false)
	$ground_particle.emitting = true
	$die_particle.emitting = true
	add_new_room($player.get_node("player_area"), $"playable_rooms/1")

func add_new_room(area, cur_room):
	var new_room = null
	if area.name != "player_area":
		return
	cur_room_id += 1
#	if cur_room_id == 2+2:
#		new_room = $room_final
#		new_room.use_collision = true
#	else:
		
	new_room = $all_rooms.get_children().pick_random().duplicate()
	new_room.get_node("mesh/StaticBody/CollisionShape").call_deferred("set", "disabled", false)
	$playable_rooms.add_child(new_room)
	
	new_room.show()
	$GUI/control/room.text = "room: " + str(cur_room_id-2)
	new_room.name = str(cur_room_id)
	new_room.rotation = cur_room.get_node("connect_out").global_rotation
	new_room.global_position -= new_room.get_node('connect_in').global_position - cur_room.get_node("connect_out").global_position
	$player.set_physics_process(false)
	yield(get_tree().create_timer(0.1), "timeout")
	$player.set_physics_process(true)

func start_battle():
	if cur_time == 0:
		set_physics_process(true)
		GameST.playlist(2)

func remove_room(area, cur_room):
	if area.name != "player_area":
		return
	$playable_rooms.get_node(str(cur_room_id-2)).queue_free()
	cur_room.get_node('request_delete_room').queue_free()

func create_box(pos:Vector3):
	var new_box = box.instance()
	new_box.position = pos
	new_box.scale = Vector3(0.01, 0.01, 0.01)
	$stuff.add_child(new_box)
	create_tween().tween_property(new_box, "scale", Vector3(1, 1, 1), 0.3).set_ease(Tween.EASE_IN_OUT)
