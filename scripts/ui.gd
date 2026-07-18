extends Control

signal set_enabled(setting: bool)

@export var player : Player
@export var turret_data : JSON
@export var hotbar : ItemList
@export var desc_bar : ItemList
@export var slide_speed : float = 10.0

var build_mode: BuildMode

@export_category("Pause Menu")
@export var continue_game_button : Button
@export var pause_menu_layer : CanvasLayer
@export var sensitivity_slider : HSlider
@export var quit_game_button : Button
@export var sens_label : Label
@export var money_label : Label

var selected = -1
var game_paused = false

var desc_tween: Tween

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_enabled.connect(player.set_enabled)
	
	continue_game_button.button_down.connect(continue_game)
	quit_game_button.button_down.connect(quit_game)
	
	sensitivity_slider.value = player.sensitivity
	sensitivity_slider.value_changed.connect(change_sensitivity)
	sens_label.text = "Sensitivity: " + str(player.sensitivity)

	build_mode = Constants.game_manager.player.build_mode

	#Set up the hotbar prices when the game is getting started.
	for i in 7:
		hotbar.set_item_text(i, str(turret_data.data[i]["cost"]) + "$")
	var stat_colors: Array[Color] = [

		Color.RED,
		Color.ORANGE,
		Color.GREEN,
		Color.CYAN,
		Color.YELLOW
	]
	for i in stat_colors.size():
		desc_bar.set_item_icon_modulate(i, stat_colors[i])
		desc_bar.set_item_custom_fg_color(i, stat_colors[i])

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

func _process(_delta: float) -> void:	
	if Input.is_action_just_pressed("escape") and not game_paused:
		pause_game()

	if game_paused:
		return
	#I know this shouldnt be here, I am lazy
	money_label.text = str(Constants.game_manager.bank)


	for i in range(1, 8):
		if Input.is_action_just_pressed(str(i)):
			select_slot(i - 1)

func select_slot(index: int) -> void:
	if selected == index:
		hotbar.deselect_all()
		selected = -1
	else:
		hotbar.select(index)
		selected = index

	if selected != -1:
		var d = turret_data.data[selected]
				
		desc_bar.set_item_text(0, str(d["damage"]))
		desc_bar.set_item_text(1, str(snapped(1 / d["seconds_between_shots"] / 1, 0.1)))
		desc_bar.set_item_text(2, str(d["max_range"]))
		desc_bar.set_item_text(3, str((1 - d["inaccuracy"]) * 100))
		desc_bar.set_item_text(4, str(d["bullet_speed"]))
		
		var selected_turret_name: String = d["name"]
		build_mode.set_turret_to_place(selected_turret_name)
	else:
		build_mode.exit_build_mode()

	animate_description_bar()

func animate_description_bar() -> void:
	# Allow ItemList/Control layout to update after changing its text.
	await get_tree().process_frame
	var closed_position := hotbar.global_position
	var open_position := closed_position - Vector2(0.0, desc_bar.size.y)
	var target_position := open_position if selected != -1 else closed_position
	# Stop the previous animation before starting another.
	if desc_tween and desc_tween.is_valid():
		desc_tween.kill()
	desc_tween = create_tween()
	desc_tween.set_trans(Tween.TRANS_QUAD)
	desc_tween.set_ease(Tween.EASE_OUT)
	desc_tween.tween_property(
		desc_bar,
		"global_position",
		target_position,
		0.2
	)
