extends Node

## Gets or sets a nested property from a Node or Array of Nodes.
## Returns the property value, or an Array of values if input is an Array.
func _get_value(value, prop: String, new_value = null):
	# Check if it's Array of Nodes
	if value is Array:
		var results = []
		for node in value:
			results.append(_get_value(node, prop, new_value))
		return results
	
	# Check Node
	if not value:
		push_error("Node '%s' not found!" % value)
		return null
	
	# Check Value
	if "." in prop: # Check if nested property
		var dot_index = prop.find(".")
		var first = prop.substr(0, dot_index)
		var rest = prop.substr(dot_index + 1)
		if value.has(first):
			return _get_value(value.get(first), rest, new_value)
		else:
			push_error("Property '%s' not found!" % first)
			return null
	else:
		if prop.ends_with("()"): # Check if method call
			var method = prop.replace("()", "")
			if value.has_method(method):
				return value.call(method)  # You can pass args if you want!
			else:
				push_error("Method '%s' not found!" % method)
				return null
		else:
			if value.has(prop): # Check if property exist
				if new_value != null: value.set(prop, new_value)
				return value.get(prop)
			else:
				push_error("Property '%s' not found!" % prop)
				return null

var warnings: Array
## Perform 'push_warning(str)' only once per instances.
func push_warning_once(warning_to_push:String):
	for warning in warnings:
		if warning == warning_to_push:
			return
	push_warning(warning_to_push)
	warnings.append(warning_to_push)
