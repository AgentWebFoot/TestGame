extends Control

signal opened ##This signal tells when the inventory scene is open.
signal closed ##This signal tells when the inventory scene is closed.

var isOpen: bool = false

func _ready() -> void:
	close()
	# Inventory starts closed

func _input(event): 
	if event.is_action_pressed("toggle_inventory"):
		if isOpen:
			close()
		else:
			open()
	# This function activates when "i" is pressed. When "i" is pressed, the var isOpen will be checked.
	# If isOpen is false the func open will be run. If isOpen is true the func close will be run.

func open(): ##This function is used to open the inventory scene and pause the game.
	visible = true
	isOpen = true
	get_tree().paused = true
	opened.emit()

func close(): ##This function is used to close the inventory scene and unpause the game.
	visible = false
	isOpen = false
	get_tree().paused = false
	closed.emit()
