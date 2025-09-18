extends Command
class_name JumpCommand

func execute(actor: Node) -> void:
	if "jump" in actor:
		actor.jump()
