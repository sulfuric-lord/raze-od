class_name Utils

static func get_damageable(node):
	var current = node
	
	while current:
		if current.has_method("take_damage"):
			print("Попали в:", current.name)
			return current
		current = current.get_parent()
	
	return null
