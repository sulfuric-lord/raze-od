class_name Utils

static func get_damageable(node):
	var current = node
	
	while current:
		if current.has_method("take_damage"):
			return current
		current = current.get_parent()
	
	return null

static func get_healable(node):
	var current = node
	
	while current:
		if current.has_method("heal"):
			return current
		current = current.get_parent()
	
	return null
