extends Control

signal set_enabled(setting: bool)

@export var player : Player
@export var turret_data : JSON
@export var hotbar : ItemList
@export var desc_bar : ItemList
@export var background_bar : ItemList
@export var slide_speed : float = 10.0

@export var cake_left_label: Label

@export var pause_hint: Label
@export var lock_hint: Label

@export var wave_indicator_label: Label

@export var end_game_panel: Panel
@export var cake_eaten_label: Label
@export var cake_protected_label: Label
@export var death_label: Label

var started: bool = false
var paused_once: bool

@export_category("Pause Menu")
@export var continue_game_button : Button
@export var pause_menu_layer : CanvasLayer
@export var sensitivity_slider : HSlider
@export var quit_game_button : Button
@export var sens_label : Label
@export_category("Money Label")
@export var money_label : Label
@export var bank_popup_scene: PackedScene
@export var popup_travel := Vector2(0, -40)
@export var popup_duration := 0.8
@export var popup_spread := PI / 6
var previous_money: int
var selected = -1
var game_paused = false
var build_mode: BuildMode
var desc_tween: Tween

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		if game_paused:
			continue_game()
		else:
			paused_once = true
			update_hint()
			pause_game()

	var player = Constants.game_manager.player
	var sensitivity = player.get_sensitivity()
	
	if event is InputEventMouseMotion and not game_paused:
		player.yaw -= event.screen_relative.x * sensitivity
		player.pitch -= event.screen_relative.y * sensitivity
		player.pitch = clamp(player.pitch, -PI / 2, PI / 2)

	if event is InputEventMouseButton and event.is_pressed() and not game_paused:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_enabled.connect(player.set_enabled)
	
	continue_game_button.button_down.connect(continue_game)
	quit_game_button.button_down.connect(quit_game)
	
	sensitivity_slider.value = player.sensitivity
	sensitivity_slider.value_changed.connect(change_sensitivity)
	sens_label.text = "Sensitivity: " + str(player.sensitivity)

	build_mode = Constants.game_manager.player.build_mode

	end_game_panel.hide()
	cake_protected_label.hide()
	cake_eaten_label.hide()
	death_label.hide()

	update_hint()
	update_cake_left()
	update_wave_indicator()
	pause_game()

	#Set up the hotbar prices when the game is getting started.
	for i in 7:
		hotbar.set_item_text(i, str(turret_data.data[i]["cost"]) + "$")
	update_hotbar_colors()
		
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
	
	previous_money = Constants.game_manager.bank
	money_label.text = str(previous_money)

func change_sensitivity(value: float) -> void:
	player.sensitivity = value
	sens_label.text = "Sensitivity: " + str(value)

func pause_game() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	game_paused = true
	set_enabled.emit(false)
	get_tree().paused = true
	pause_menu_layer.visible = true

func continue_game() -> void:
	game_paused = false
	set_enabled.emit(true)
	get_tree().paused = false
	pause_menu_layer.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	started = true

func quit_game() -> void:
	get_tree().quit()

func _process(_delta: float) -> void:		
	if game_paused:
		return
	
	update_hint()
	update_cake_left()
	update_wave_indicator()
	check_game_end()

	var current_money: int = Constants.game_manager.bank

	if current_money != previous_money:
		var difference := current_money - previous_money
		if difference > 0:
			show_money_popup(difference)
		previous_money = current_money
		money_label.text = str(current_money)
		update_hotbar_colors()

	for i in range(1, 8):
		if Input.is_action_just_pressed(str(i)):
			select_slot(i - 1)
	
func update_hotbar_colors() -> void:
	var bank := Constants.game_manager.bank
	for i in range(7):
		var cost: int = turret_data.data[i]["cost"]	
			
		if bank >= cost:
			hotbar.set_item_custom_fg_color(i, Color.WHITE)
			hotbar.set_item_custom_fg_color(i, Color.WHITE)
			hotbar.set_item_icon_modulate(i, Color.WHITE)
			background_bar.set_item_icon_modulate(i, background_bar.get_item_icon_modulate(i).lightened(0.35))
		else:
			hotbar.set_item_custom_fg_color(i, Color.GRAY)
			hotbar.set_item_custom_fg_color(i, Color.BLACK)
			hotbar.set_item_icon_modulate(i, Color.BLACK)
			background_bar.set_item_icon_modulate(i, background_bar.get_item_icon_modulate(i).darkened(0.35))


func show_money_popup(amount: int) -> void:
	var popup := bank_popup_scene.instantiate() as Label
	add_child(popup)

	# Spawn it beside the money counter.
	popup.global_position = Vector2(
		money_label.global_position.x + money_label.get_minimum_size().x + 10.0,
		money_label.global_position.y + 20.0
	)

	popup.show_value(
		amount,
		popup_travel,
		popup_duration,
		popup_spread
	)

func update_cake_left():
	var game_manager = Constants.game_manager
	var health_left = int(round(game_manager.tower_health / game_manager.max_tower_health * 100))
	cake_left_label.text = "Cake left: %s%%" % health_left

func select_slot(index: int) -> void:
	if selected == index:
		hotbar.deselect_all()
		selected = -1
	else:
		hotbar.select(index)
		selected = index

	if selected != -1:
		var d = turret_data.data[selected]
				
		desc_bar.set_item_text(0, str(d["damage"]) + "\n")
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

func update_hint() -> void:
	hide_hint()

	if not started:
		return

	if build_mode.enabled and not build_mode.locked_once:
		lock_hint.show()
		return

	if not paused_once:
		pause_hint.show()

func hide_hint() -> void:
	pause_hint.hide()
	lock_hint.hide()

func update_wave_indicator() -> void:
	var game_manager = Constants.game_manager
	if not game_manager.before_wave:
		wave_indicator_label.text = "Wave %s" % game_manager.wave_no
	elif is_instance_valid(game_manager.before_first_wave_timer):
		var seconds = int(round(game_manager.before_first_wave_timer.time_left))

		if game_manager.wave_no != -1:
			wave_indicator_label.text = "Next wave starts in %s seconds" % seconds
		else:
			wave_indicator_label.text = "First wave starts in %s seconds" % seconds
	else:
		wave_indicator_label.text = ""

func check_game_end():
	if Constants.game_manager.tower_health <= 0:
		pause_game()
		end_game_panel.show()
		cake_eaten_label.show()
		pause_menu_layer.visible = false

	if Constants.game_manager.cake_protected:
		pause_game()
		end_game_panel.show()
		cake_protected_label.show()
		pause_menu_layer.visible = false

	if Constants.game_manager.player.hit_ground:
		pause_game()
		end_game_panel.show()
		death_label.show()		
		pause_menu_layer.visible = false
