extends Control

@onready var list_root: VBoxContainer = $VBoxContainer
var message_label: Label

var _capturing := false
var _capturing_action: StringName = ""
var _capturing_btn: Button

func _ready():
	# Optional message label lookup (safe if it doesn't exist)
	if has_node("MessageLabel"):
		message_label = $MessageLabel
	_show_message("") # clear

	_build_rows()
	InputManager.binding_changed.connect(_on_binding_changed)
	InputManager.binding_conflict.connect(_on_binding_conflict)

func _build_rows():
	# Clear previous
	for c in list_root.get_children():
		c.queue_free()

	for action in InputManager.get_actions():
		var row := HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.alignment = BoxContainer.ALIGNMENT_BEGIN

		var name_label := Label.new()
		name_label.text = String(action).capitalize()
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		# Bind button (toggles into "listening" mode)
		var bind_btn := Button.new()
		bind_btn.text = InputManager.get_action_event_text(action)
		bind_btn.toggle_mode = true
		bind_btn.focus_mode = Control.FOCUS_ALL
		bind_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		bind_btn.pressed.connect(func():
			if bind_btn.button_pressed:
				_start_capture(action, bind_btn)
			else:
				_cancel_capture(bind_btn)
		)

		row.add_child(name_label)
		row.add_child(bind_btn)
		list_root.add_child(row)

	# Separator + Reset
	var sep := HSeparator.new()
	list_root.add_child(sep)

	var reset_btn := Button.new()
	reset_btn.text = "Reset to Defaults"
	reset_btn.pressed.connect(func():
		if _capturing:
			_cancel_capture(_capturing_btn)
		InputManager.reset_to_defaults()
		_show_message("Bindings reset to defaults")
	)
	list_root.add_child(reset_btn)

func _start_capture(action: StringName, button: Button) -> void:
	_capturing = true
	_capturing_action = action
	_capturing_btn = button
	_capturing_btn.text = "Press a key… (Esc to cancel)"
	_disable_other_rows(button)
	_show_message("Listening for %s…" % [String(action).capitalize()])

func _cancel_capture(button: Button) -> void:
	_capturing = false
	_capturing_action = ""
	_capturing_btn = null
	button.button_pressed = false
	button.text = InputManager.get_action_event_text(_find_action_for_button(button))
	_enable_all_rows()
	_show_message("")

func _finish_capture(new_event: InputEvent) -> void:
	# stop listening first so UI updates cleanly
	var btn := _capturing_btn
	var action := _capturing_action
	_capturing = false
	_capturing_action = ""
	_capturing_btn = null
	if is_instance_valid(btn):
		btn.button_pressed = false
	_enable_all_rows()

	InputManager.rebind_action(action, new_event)
	_show_message("%s bound to %s" % [String(action).capitalize(), new_event.as_text()])

func _on_binding_changed(_action: StringName, _event_text: String) -> void:
	# If not capturing, rebuild; otherwise the button text was already updated by _finish_capture
	if not _capturing:
		_build_rows()

func _on_binding_conflict(action: StringName, other: StringName) -> void:
	# Stay in capture mode; user can press another key
	_show_message("%s already bound to %s — press another key"
		% [String(action).capitalize(), String(other).capitalize()])
	if is_instance_valid(_capturing_btn):
		# brief visual feedback
		_capturing_btn.modulate = Color(1, 0.75, 0.75) # light red
		await get_tree().process_frame
		_capturing_btn.modulate = Color(1, 1, 1)

func _unhandled_input(event: InputEvent) -> void:
	if not _capturing:
		return

	# Cancel with Esc / Right Mouse
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_cancel_capture(_capturing_btn)
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		_cancel_capture(_capturing_btn)
		get_viewport().set_input_as_handled()
		return

	# Accept keyboard
	if event is InputEventKey and event.pressed and not event.echo:
		_finish_capture(event)
		get_viewport().set_input_as_handled()
		return

	# Accept gamepad button
	if event is InputEventJoypadButton and event.pressed:
		_finish_capture(event)
		get_viewport().set_input_as_handled()
		return

	# (Optional) accept mouse buttons / joy axes here

# ---------- helpers ----------

func _find_action_for_button(button: Button) -> StringName:
	# Walk up to the row and find the Label text
	var row := button.get_parent()
	for child in row.get_children():
		if child is Label:
			return StringName((child as Label).text.to_lower())
	return StringName("")

func _disable_other_rows(active_btn: Button) -> void:
	for row in list_root.get_children():
		if row is HBoxContainer:
			for n in row.get_children():
				if n is Button and n != active_btn:
					(n as Button).disabled = true

func _enable_all_rows() -> void:
	for row in list_root.get_children():
		if row is HBoxContainer:
			for n in row.get_children():
				if n is Button:
					(n as Button).disabled = false

func _show_message(msg: String) -> void:
	if message_label and is_instance_valid(message_label):
		message_label.text = msg
	else:
		if msg != "":
			print(msg)
