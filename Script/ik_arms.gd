extends Node3D

@export var left_arm_ik: SkeletonIK3D
@export var right_arm_ik: SkeletonIK3D
@export var left_arm_target: Node3D
@export var right_arm_target: Node3D
@export var objects: Array[Node3D]
@export var max_eligable_length: float = 1.0
@export var parentTransform: Node3D

var shortest_left_position: float
var shortest_right_position: float
var left_ik_enable: bool = false
var right_ik_enable: bool = false

func getIKTargetPosition() -> void:
	var min_length_left: float = 1000.0
	var min_length_right: float = 1000.0
	left_ik_enable = false
	right_ik_enable = false
	
	var vec: Vector3 = Vector3.ZERO
	var dis: float = 0.0
	for object in objects:
		vec = object.global_transform.origin - left_arm_target.global_transform.origin
		dis = vec.length()
		if dis < min_length_left and dis < max_eligable_length:
			min_length_left = dis
			left_arm_target.global_transform.origin = object.global_transform.origin
			left_ik_enable = true
		vec = object.global_transform.origin - right_arm_target.global_transform.origin
		dis = vec.length()
		if dis < min_length_right and dis < max_eligable_length:
			min_length_right = dis
			right_arm_target.global_transform.origin = object.global_transform.origin
			right_ik_enable = true

func _ready() -> void:
	left_arm_ik.active = true
	right_arm_ik.active = true
	left_arm_ik.influence = 0.0
	right_arm_ik.influence = 0.0
	left_arm_ik.target = left_arm_target.transform
	right_arm_ik.target = right_arm_target.transform
	left_arm_ik.start()
	right_arm_ik.start()

func _process(delta: float) -> void:
	transform.origin = parentTransform.global_transform.origin
	getIKTargetPosition()
	if left_ik_enable:
		left_arm_ik.influence = 1.0
	else:
		left_arm_ik.influence = 0.0
	if right_ik_enable:
		right_arm_ik.influence = 1.0
	else:
		right_arm_ik.influence = 0.0
