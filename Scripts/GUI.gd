extends CanvasLayer

func set_all_settings():
	#Sentetive
	$"../player".mouse_sentetive = get_node("settings/Panel/VBoxContainer/Label/HSlider").value
	$"../player".find_sentetive()
	$"../player".str_otdacha = get_node("settings/Panel/VBoxContainer/Label6/HSlider").value
	AudioServer.set_bus_volume_db(1, linear2db(get_node("settings/Panel/VBoxContainer/Label2/HSlider").value))
	AudioServer.set_bus_volume_db(2, linear2db(get_node("settings/Panel/VBoxContainer/Label3/HSlider").value))
	OS.window_fullscreen = get_node("settings/Panel/VBoxContainer/Label4/CheckButton").pressed
	OS.vsync_enabled = get_node("settings/Panel/VBoxContainer/Label5/CheckButton").pressed
	
func connecting():
	get_node("settings/Panel/VBoxContainer/Label/HSlider").connect("value_changed", self, "ch_sentetive")
	get_node("settings/Panel/VBoxContainer/Label6/HSlider").connect("value_changed", self, "ch_screenshake")
	get_node("settings/Panel/VBoxContainer/Label2/HSlider").connect("value_changed", self, "ch_music")
	get_node("settings/Panel/VBoxContainer/Label3/HSlider").connect("value_changed", self, "ch_sounds")
	get_node("settings/Panel/VBoxContainer/Label4/CheckButton").connect("toggled", self, "ch_fullscreen")
	get_node("settings/Panel/VBoxContainer/Label5/CheckButton").connect("toggled", self, "ch_vsync")

func _ready():
	GameST.create_settings()

func _input(event):
	if event.is_action_pressed("settings") and not $"../player".died:
		$settings.visible = !$settings.visible
		if $settings.visible:
			get_tree().paused = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			GameST.make_quiet(1)
		else :
			get_tree().paused = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			GameST.make_loud(1)

func ch_sentetive(value):
	$"../player".mouse_sentetive = value
	$"../player".find_sentetive()
	$settings/Panel/VBoxContainer/Label/Label.text = str(value)

func ch_screenshake(value):
	$"../player".str_otdacha = value
	$settings/Panel/VBoxContainer/Label6/Label.text = str(value)

func ch_music(value):
	AudioServer.set_bus_volume_db(1, linear2db(value))
	$settings/Panel/VBoxContainer/Label2/Label.text = str(value)

func ch_sounds(value):
	AudioServer.set_bus_volume_db(2, linear2db(value))
	$settings/Panel/VBoxContainer/Label3/Label.text = str(value)

func ch_fullscreen(button_pressed):
	OS.window_fullscreen = button_pressed

func ch_vsync(button_pressed):
	OS.vsync_enabled = button_pressed

func leave():
	get_tree().quit()

func again():
	GameST.dada =$settings.duplicate()
	get_tree().reload_current_scene()
