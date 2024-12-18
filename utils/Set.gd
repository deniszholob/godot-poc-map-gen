extends Object

class_name Set

var _dict := {}

func _init(elems: Array = []) -> void:
	add_all(elems)

func add(el) -> void:
	_dict[el] = el

func add_all(elems: Array) -> void:
	for el in elems:
		add(el)

func get_elements() -> Array:
	return _dict.values()
