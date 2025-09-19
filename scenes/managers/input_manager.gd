extends Node


signal binding_changed(action: StringName, event_text: String)
signal binding_conflict(action: StringName, conflicting_action: StringName)

const CONFIG_PATH := "res://configs/keybinds.cfg"
const CONFIG_SECTION := "bindings"

var default_bindings: Dictionary = {
	"jump": InputEventKey.new(),
	"dash": InputEventKey.new(),
	"attack": InputEventKey.new()
}

var _commands: Dictionary = {}

func _ready() -> void:
	default_bindings["jump"] = Key.KEY_C
	default_bindings["dash"] = Key.KEY_Z
	default_bindings["attack"] = Key.KEY_X
	
	_commands = {
		"jump": JumpCommand.new(),
		"dash": DashCommand.new(),
		"attack": AttackCommand.new()
	}
	
	_ensure_actions_exists(default_bindings.keys())
	load_bindings()
	
func _ensure_actions_exists(actions: Array) -> void:
	for action in actions:
		if not InputMap.has_action(action):
			InputMap.add_action(action)

func apply_bindings(bindings: Dictionary) -> void:
	for action in bindings.keys():
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, _make_key_event(bindings[action]))

func load_bindings() -> void:
	var file := ConfigFile.new()
	var err := file.load(CONFIG_PATH)
	var bindings := {} as Dictionary
	
	if err != OK:
		bindings = default_bindings.duplicate(true)
		apply_bindings(bindings)
		save_bindings()
		return
	
	for action in default_bindings.keys():
		var serialized = file.get_value(CONFIG_SECTION, String(action), "")
		if serialized == "":
			bindings[action] = default_bindings[action]
		else:
			var ev := _deserialize_event(serialized)
			bindings[action] = ev if ev != null else default_bindings[action]

func save_bindings() -> void:
	var file := ConfigFile.new()
	file.load(CONFIG_PATH)
	
	for action in default_bindings.keys():
		var evs := InputMap.action_get_events(action)
		var ev: InputEvent = evs[0] if evs.size() > 0 else default_bindings[action]
		file.set_value(CONFIG_PATH, String(action), _serialize_event(ev))
	
	file.save(CONFIG_PATH)

func rebind_action(action: StringName, new_event: InputEvent) -> void:
	var conflict_action := _find_conflict_action(action, new_event)
	if conflict_action != "":
		emit_signal("binding_conflict", action, conflict_action)
		return
	
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, new_event)
	save_bindings()
	emit_signal("binding_changed", action, new_event.as_text())

func reset_to_defaults() -> void:
	apply_bindings(default_bindings)
	save_bindings()
	for action in default_bindings.keys():
		emit_signal("binding_changed", action, str(default_bindings[action]))

func get_action_event_text(action: StringName) -> String:
	var evs := InputMap.action_get_events(action)
	return (evs[0] as InputEvent).as_text() if evs.size() > 0 else "Unbound"

func get_actions() -> Array:
	return default_bindings.keys()

func execute_if_pressed(actor: Node) -> void:
	for action in _commands.keys():
		if Input.is_action_just_pressed(action):
			(_commands[action] as Command).execute(actor)

# ----------- HELPERS -----------

func _make_key_event(keycode: int, shift:=false, alt:=false, ctrl:=false, meta:=false) -> InputEventKey:
	var ev := InputEventKey.new()
	ev.keycode = keycode
	ev.shift_pressed = shift
	ev.alt_pressed = alt
	ev.ctrl_pressed = ctrl
	ev.meta_pressed = meta
	return ev

func _find_conflict_action(target_action: StringName, new_event: InputEvent) -> StringName:
	for action in default_bindings.keys():
		if action == target_action:
			continue
		
		for ev in InputMap.action_get_events(action):
			if ev.is_match(new_event, true):
				return action
	
	return ""

func _serialize_event(ev) -> String:
	# Simple scheme: type|keycode or type|joy_button or type|joy_axis|value
	# You can extend this for mouse, modifiers, etc.
	if ev is InputEventKey:
		return "key|" + str((ev as InputEventKey).keycode)
	if ev is InputEventJoypadButton:
		return "jb|" + str((ev as InputEventJoypadButton).button_index)
	if ev is InputEventJoypadMotion:
		var jm := ev as InputEventJoypadMotion
		return "jm|" + str(jm.axis) + "|" + str(jm.axis_value)
		
	return "unknown|"

func _deserialize_event(s: String) -> InputEvent:
	var parts := s.split("|")
	if parts.size() == 0:
		return null
	
	match parts[0]:
		"key":
			if parts.size() >= 2:
				var ie := InputEventKey.new()
				ie.keycode = int(parts[1])
				return ie
		"jb":
			if parts.size() >= 2:
				var jb := InputEventJoypadButton.new()
				jb.button_index = int(parts[1])
				return jb
		"jm":
			if parts.size() >= 3:
				var jm := InputEventJoypadMotion.new()
				jm.axis = int(parts[1])
				jm.axis_value = float(parts[2])
				return jm
	return null
