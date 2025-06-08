extends Node3D

# Influence from 0 -> 1
@onready var head: LookAtModifier3D = $Skeleton3D/HeadLookAt
# Influence from 0 -> 0.4
@onready var spine: LookAtModifier3D = $Skeleton3D/SpineLookAt
@onready var Creature = get_parent().get_node("Creature")
@onready var creature: Node3D = Creature.get_node("CharacterBody3D")
@onready var sight1: Node3D = Creature.get_node("CharacterBody3D/SightTarget1")
@onready var sight2: Node3D = Creature.get_node("CharacterBody3D/SightTarget2")
@onready var sight3: Node3D = Creature.get_node("CharacterBody3D/SightTarget3")

@export var eye: Node3D
@export var max_head_influence: float = 1.0
@export var max_spine_influence: float = 0.4
@export var turn_speed_towards_creature: float = 4.0
@export var turn_speed_back: float = 2.0
@export var time_until_turn_back: float = 3.0
@export var time_until_restart: float = 2.0
@export var signalManager: Node3D

var creature_is_visible: bool = false
var has_turned: bool = false
var restarting: bool = false

func isCreatureVisible(target: Node3D) -> bool:
	var space_state = get_world_3d().direct_space_state
	var origin = eye.global_transform.origin
	var target_pos = target.global_transform.origin
	var params = PhysicsRayQueryParameters3D.create(
		origin,
		target_pos
	)
	var result = space_state.intersect_ray(params)
	if result:
		return result.collider == creature
	else:
		return false

func detectCreature() -> void:
	if isCreatureVisible(sight1) or isCreatureVisible(sight2) or isCreatureVisible(sight3):
		creature_is_visible = true
		restartGame()
	if not creature_is_visible:
		await get_tree().create_timer(time_until_turn_back).timeout
		has_turned = false

func turnAndCheck(delta: float) -> void:
	var weight: float = 1 - exp(-turn_speed_towards_creature * delta)
	head.influence = lerp(head.influence, max_head_influence, weight)
	spine.influence = lerp(spine.influence, max_spine_influence, weight)
	
	if head.influence >= max_head_influence - 0.01 or spine.influence >= max_spine_influence - 0.01:
		detectCreature()

func turnBackToNormal(delta: float) -> void:
	var weight: float = 1 - exp(-turn_speed_back * delta)
	head.influence = lerp(head.influence, 0.0, weight)
	spine.influence = lerp(spine.influence, 0.0, weight)

func onObjectBroken() -> void:
	has_turned = true

func onAllObjectBroken() -> void:
	queue_free()

func restartGame():
	if restarting:
		return
	restarting = true
	call_deferred("changeScene")

func changeScene():
	signalManager.disconnect("object_broken", onObjectBroken)
	signalManager.disconnect("all_object_broken", onAllObjectBroken)
	get_tree().change_scene_to_file("res://Scene/Retry.tscn")

func _ready() -> void:
	signalManager.connect("object_broken", onObjectBroken)
	signalManager.connect("all_object_broken", onAllObjectBroken)
	head.target_node = creature.get_path()
	spine.target_node = creature.get_path()
	
	head.influence = 0.0
	spine.influence = 0.0
	head.active = true
	spine.active = true

func _process(delta: float) -> void:
	if creature_is_visible:
		return
	if restarting:
		return
	
	if has_turned:
		turnAndCheck(delta)
	else:
		turnBackToNormal(delta)
	
	var creature_position = creature.global_transform.origin
	var eye_position = eye.global_transform.origin
	var creature_direction = (creature_position - eye_position).normalized()
	var man_forward_direction: Vector3 = eye.transform.basis.z.normalized()
	var angle = creature_direction.dot(man_forward_direction)
	if angle >= 0.3:
		has_turned = true
