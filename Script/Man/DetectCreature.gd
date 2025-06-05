extends Node3D

@export var creature: Node3D
@export var eye: Node3D
@export var sight1: Node3D
@export var sight2: Node3D
@export var sight3: Node3D

var creature_is_visible: bool = false

func isCreatureVisible(target: Node3D) -> bool:
	var space_state = get_world_3d().direct_space_state
	var origin = eye.global_transform.origin
	var target_pos = target.global_transform.origin
	var params = PhysicsRayQueryParameters3D.create(
		origin,
		target_pos,
		1
	)
	var result = space_state.intersect_ray(params)
	if result:
		return result.collider == creature
	else:
		return false
		

func _process(delta: float) -> void:
	var visible1: bool = isCreatureVisible(sight1)
	var visible2: bool = isCreatureVisible(sight2)
	var visible3: bool = isCreatureVisible(sight3)
	if visible1 or visible2 or visible3:
		creature_is_visible = true # Will make this trigger a signal
