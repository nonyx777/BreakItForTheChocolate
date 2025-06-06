extends Node3D

# Influence from 0 -> 1
@onready var head: LookAtModifier3D = $Skeleton3D/HeadLookAt
# Influence from 0 -> 0.4
@onready var spine: LookAtModifier3D = $Skeleton3D/SpineLookAt

@export var creature: Node3D
@export var eye: Node3D
@export var sight1: Node3D
@export var sight2: Node3D
@export var sight3: Node3D
@export var max_head_influence: float = 1.0
@export var max_spine_influence: float = 0.4
@export var turn_speed_towards_creature: float = 4.0
@export var turn_speed_back: float = 2.0
@export var time_until_turn_back: float = 3.0

signal object_broken()
signal creature_not_in_sight()
var creature_is_visible: bool = false
var has_turned: bool = false

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

func detectCreature() -> void:
	var visible1: bool = isCreatureVisible(sight1)
	var visible2: bool = isCreatureVisible(sight2)
	var visible3: bool = isCreatureVisible(sight3)
	if visible1 or visible2 or visible3:
		creature_is_visible = true # Will make this trigger a signal
	if not creature_is_visible:
		await get_tree().create_timer(time_until_turn_back).timeout
		has_turned = false

func turnAndCheck(delta: float) -> void:
	var weight: float = 1 - exp(-turn_speed_towards_creature * delta)
	head.influence = lerp(head.influence, max_head_influence, weight)
	spine.influence = lerp(spine.influence, max_spine_influence, weight)
	
	if head.influence >= max_head_influence - 0.1 or spine.influence >= max_spine_influence - 0.1:
		detectCreature()

func turnBackToNormal(delta: float) -> void:
	var weight: float = 1 - exp(-turn_speed_back * delta)
	head.influence = lerp(head.influence, 0.0, weight)
	spine.influence = lerp(spine.influence, 0.0, weight)

func onObjectBroke() -> void:
	has_turned = true

func _ready() -> void:
	object_broken.connect(onObjectBroke)
	head.influence = 0.0
	spine.influence = 0.0
	head.active = true
	spine.active = true

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Jump"):
		object_broken.emit()
	if has_turned:
		turnAndCheck(delta)
	else:
		turnBackToNormal(delta)
