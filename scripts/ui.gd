extends Control
signal set_enabled(setting: bool)
@export var player : Player
@export var turret_data : JSON
@export var hotbar : ItemList
@export var desc_bar : ItemList
@export var slide_speed : float = 10.0
@export_category("Puase Menu")
@export var continue_game_button : Button
@export var pause_menu_layer : CanvasLayer
@export var sensitivity_slider : HSlider
@export var quit_game_button : Button
@export var sens_label : Label
@export var money_label : Label
var open_position : Vector2
var closed_position : Vector2
var selected = -1
var game_paused = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	await get_tree().process_frame
	set_enabled.connect(player.set_enabled)
	
	continue_game_button.button_down.connect(continue_game)
	quit_game_button.button_down.connect(quit_game)
	
	sensitivity_slider.value = player.sensitivity
	sensitivity_slider.value_changed.connect(change_sensitivity)
	sens_label.text = "Sensitivity: " + str(player.sensitivity)

	#Set up the hotbar prices when the game is getting started.
	for i in 7:
		hotbar.set_item_text(i, str(turret_data.data[i]["cost"]) + "$")
func change_sensitivity(value: float) -> void:
	player.sensitivity = value
	sens_label.text = "Sensitivity: " + str(value)

func pause_game() -> void:
	game_paused = true
	set_enabled.emit(false)
	get_tree().paused = true
	pause_menu_layer.visible = true
	return

func continue_game() -> void:
	game_paused = false
	set_enabled.emit(true)
	get_tree().paused = false
	pause_menu_layer.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	return

func quit_game() -> void:
	get_tree().quit()

func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("escape") and not game_paused:
		pause_game()

	closed_position = hotbar.global_position 
	open_position = hotbar.global_position - Vector2(0,desc_bar.size.y)
	if game_paused:
		return
	
	money_label.text = str(Constants.game_manager.bank)
	
	if selected != -1:
		desc_bar.global_position = desc_bar.global_position.lerp(
			open_position,
			clamp(slide_speed * delta, 0.0, 1.0)
		)
	else:
		desc_bar.global_position = desc_bar.global_position.lerp(
			closed_position,
			clamp(slide_speed * delta, 0.0, 1.0)
		)
	
	if selected != -1:
		desc_bar.set_item_text(0, str(turret_data.data[selected]["damage"]))
		desc_bar.set_item_text(1, str(snapped(1 / turret_data.data[selected]["seconds_between_shots"] / 1, 0.1)))
		desc_bar.set_item_text(2, str(turret_data.data[selected]["max_range"]))
		desc_bar.set_item_text(3, str((1 - turret_data.data[selected]["inaccuracy"]) * 100))
		desc_bar.set_item_text(4, str(turret_data.data[selected]["bullet_speed"]))
	
	#Hotbar selection
	if Input.is_action_just_pressed("1"):
		if selected == 0:
			hotbar.deselect_all()
			selected = -1
		else:
			selected = 0
			hotbar.select(0)
	
	if Input.is_action_just_pressed("2"):
		if selected == 1:
			hotbar.deselect(1)
			selected = -1
		else:
			selected = 1
			hotbar.select(1)
	
	if Input.is_action_just_pressed("3"):
		if selected == 2:
			hotbar.deselect(2)
			selected = -1
		else:
			selected = 2
			hotbar.select(2)
	
	if Input.is_action_just_pressed("4"):
		if selected == 3:
			hotbar.deselect(3)
			selected = -1
		else:
			selected = 3
			hotbar.select(3)
	
	if Input.is_action_just_pressed("5"):
		if selected == 4:
			hotbar.deselect(4)
			selected = -1
		else:
			selected = 4
			hotbar.select(4)
	
	if Input.is_action_just_pressed("6"):
		if selected == 5:
			hotbar.deselect(5)
			selected = -1
		else:
			selected = 5
			hotbar.select(5)
	
	if Input.is_action_just_pressed("7"):
		if selected == 6:
			hotbar.deselect(6)
			selected = -1
		else:
			selected = 6
			hotbar.select(6)
