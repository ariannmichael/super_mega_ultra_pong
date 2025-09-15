extends MarginContainer

@export var speed: float = 8.0
@export var amplitude: float = 1.5

var t := 0.0
var base_top := 0
var base_bottom := 0

func _ready() -> void:
	base_top = get_theme_constant("margin_top")
	base_bottom = get_theme_constant("margin_bottom")

func _process(delta: float) -> void:
	t += delta * speed
	var d := int(round(sin(t) * amplitude))
	# Move content down by increasing top margin, and keep total height constant by reducing bottom
	add_theme_constant_override("margin_top", base_top + d)
	add_theme_constant_override("margin_bottom", base_bottom - d)
