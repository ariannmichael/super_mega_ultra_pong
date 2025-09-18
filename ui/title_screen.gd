extends CanvasLayer

@onready var buttons_container: VBoxContainer = $Control/MarginContainer/VBoxContainer/ButtonsContainer


func _on_button_start_pressed() -> void:
	$"/root/LevelManager".increment_level()


func _on_button_options_pressed() -> void:
	$"/root/LevelManager".change_level(3)


func _on_button_credits_pressed() -> void:
	$"/root/LevelManager".change_level(2)
