extends Command
class_name DashCommand

func execute(actor: Node) -> void:
	if "dash" in actor:
		actor.dash()
