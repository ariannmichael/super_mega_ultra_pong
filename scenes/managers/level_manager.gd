extends Node

@export var level_scenes: Array[PackedScene]

var current_index_level = 0

func change_level(level_index):
	current_index_level = level_index
	if(current_index_level >= level_scenes.size()):
		current_index_level = 0
		
	call_deferred("update_scene")

func increment_level():
	change_level(current_index_level + 1)

func update_scene():
	get_tree().change_scene_to_packed(level_scenes[current_index_level])
