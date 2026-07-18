extends Control
@export var hotbar : ItemList
@export var turret_data : JSON
@export var text_desc : Label 
var selected = -1

func _ready() -> void:
	#Set up the hotbar prices when the game is getting started.
	for i in 7:
		hotbar.set_item_text(i, str(turret_data.data[i]["cost"]) + "$")
	
func _process(delta: float) -> void:
	
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
	
