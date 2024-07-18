extends Spatial

func _ready():
	$doors.play("RESET")
	$request_new_room.connect("area_entered", get_tree().current_scene, "add_new_room", [self])
	$request_new_room.connect("area_entered", self, "start_battle")
	$request_delete_room.connect("area_entered", get_tree().current_scene, "remove_room", [self])

export var count_enemies:int = 1
var enemies:int = 0

func minus_one():
	enemies -= 1
	if enemies == 0:
		end_battle()

func create_new_enemy():
	var new_enemy = get_tree().current_scene.get_node("all_enemies").get_children().pick_random().duplicate()
	$enemies.add_child(new_enemy)
	new_enemy.global_position = get_node("spawner_enemies").get_child(0).global_position
	get_node("spawner_enemies").get_child(0).free()
	new_enemy.connect("im_die", self, "minus_one")
	yield(get_tree().create_timer(0.6), "timeout")
	new_enemy.enable()
	
func start_battle(area):
	if count_enemies == 0 or area.name != "player_area":
		return
	$request_new_room.queue_free()
	for ammo in get_tree().get_nodes_in_group('ammos'):
		ammo.queue_free()
	get_tree().current_scene.start_battle()
	$doors.play("doors_down")
	enemies = $spawner_enemies.get_child_count()
	for i in range($spawner_enemies.get_child_count()):
		create_new_enemy()
		
func end_battle():
	$doors.play("next_door")
