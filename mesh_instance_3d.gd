extends MeshInstance3D

func _ready():
	# Begin draw.
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	$RampCol.shape

	# Prepare attributes for add_vertex.
	mesh.surface_set_normal(Vector3(0, 0, 1))
	mesh.surface_set_uv(Vector2(0, 0))
	# Call last for each vertex, adds the above attributes.
	mesh.surface_add_vertex(Vector3(-1, -1, 0))

	mesh.surface_set_normal(Vector3(0, 0, 1))
	mesh.surface_set_uv(Vector2(0, 1))
	mesh.surface_add_vertex(Vector3(-1, 1, 0))

	mesh.surface_set_normal(Vector3(0, 0, 1))
	mesh.surface_set_uv(Vector2(1, 1))
	mesh.surface_add_vertex(Vector3(1, 1, 0))

	# End drawing.
	mesh.surface_end()
