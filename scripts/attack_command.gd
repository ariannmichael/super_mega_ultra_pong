extends Command
class_name AttackCommand

func execute(actor: Node) -> void:
	if "attack" in actor:
		actor.attack()
