extends Node2D

func set_hp_points(point):
	$ProgressBar.value = point

func decrease(point):
	var aux = $ProgressBar.value - point
	if aux < 0:
		aux = 0
	$ProgressBar.value = aux
