extends Node

var all_music = {"0": [1, load("res://Audio/Music/1339999.mp3"), "splicrr", "ImFloatingEndlessly\nThroughSpace"],
				"1": [0.6, load("res://Audio/Music/1336643.mp3"), "Ryzmik", "Digital Obsession"], #0.6
				"2": [0.6, load("res://Audio/Music/1340579.mp3"), "398utubzyt", "Rockier Encountier"], #0.6
				"3": [0.56, load("res://Audio/Music/1340556.mp3"), "RC75", "Turbulence (VIP)"], #0.56
				"4": [0.44, load("res://Audio/Music/1340555.mp3"), "Zeddius", "Miracle"] #0.44
}

var cur_song:Array = []
var need_stop_list:bool = false
var one_hp:bool = false
var settings = preload("res://Scenes/settings.tscn").instance()
var dada = null

func create_settings():
	get_tree().current_scene.get_node("GUI").add_child_below_node(get_tree().current_scene.get_node("GUI/control"), dada)
	get_tree().current_scene.get_node("GUI").connecting()
	get_tree().current_scene.get_node("GUI").set_all_settings()

func _ready():
	randomize()
	dada = settings

func playlist(fade:float = 0.5):
	var all_songs = all_music.keys()
	all_songs.shuffle()
	for song in all_songs:
		play(song, fade)
		
		yield($player, "finished")
		yield(get_tree().create_timer(1), "timeout")
		if need_stop_list:
			break
	if not need_stop_list:
		playlist(fade)
	else :
		need_stop_list = false

func stoplist(fade:float = 0.5):
	need_stop_list = true
	stop(fade)

func play(song:String, fade:float = 0.5):
	var cur_scene = get_tree().current_scene
	cur_song = all_music[song]
	$player.volume_db = linear2db(0.01)
	$player.stream = cur_song[1]
	$player.play()
	create_tween().tween_property($player, "volume_db", linear2db(cur_song[0]), fade)
	cur_scene.gui.get_node("control/song_titles/credits/author").text = cur_song[2]
	cur_scene.gui.get_node("control/song_titles/credits/song").text = cur_song[3]
	cur_scene.show_credits.play("show_autor")

func stop(fade:float = 0.5):
	var da = create_tween()
	da.tween_property($player, "volume_db", linear2db(0.01), fade)
	da.tween_callback($player, "stop")

func pause(fade:float = 0.5):
	var da = create_tween()
	da.tween_property($player, "volume_db", linear2db(0.01), fade)
	da.tween_property($player, "stream_paused", true, 0)

func resume(fade:float = 0.5):
	var da = create_tween()
	da.tween_property($player, "stream_paused", true, 0)
	da.tween_property($player, "volume_db", linear2db(cur_song[0]), fade)

func make_quiet(fade:float = 0.5):
	if not cur_song:
		return
	var da = create_tween()
	da.tween_property($player, "volume_db", linear2db(cur_song[0]*0.5), fade)

func make_loud(fade:float = 0.5):
	if not cur_song:
		return
	var da = create_tween()
	da.tween_property($player, "volume_db", linear2db(cur_song[0]), fade)
