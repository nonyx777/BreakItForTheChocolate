extends RigidBody3D

@onready var stm_instance = $STMCachedInstance3D
@onready var collisionShape = $CollisionShape3D
@onready var signalManager = get_parent().get_parent().get_parent().get_node("SignalManager")
@onready var sfxPlayer = get_parent().get_node("AudioStreamPlayer")

var smash_once: bool = true

func _ready():
	contact_monitor = true
	max_contacts_reported = 50

func smash() -> void:
	if !stm_instance:
		return
	# Break
	stm_instance.smash_the_mesh()
	# Apply an "explode" impulse to each fragment/chunk
	# Define a callback to apply an impulse to a rigid body chunk
	var explode_callback = func(rb: RigidBody3D, _from):
		rb.call_deferred("apply_impulse", -rb.position.normalized() * Vector3(1, -1, 1) * 5.0)
	# Apply the callback to each chunk of the mesh
	stm_instance.chunks_iterate(explode_callback)
	signalManager.emit_signal("object_broken")
	signalManager.smashed_objects += 1
	sfxPlayer.play()
	if signalManager.smashed_objects == 11: # Should make it dynamic
		signalManager.emit_signal("all_object_broken")

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	for i in state.get_contact_count():
		var collider = state.get_contact_collider_object(i)
		if collider and collider is CollisionObject3D:
			if (collider.collision_layer & (1 << 2)) != 0:  # Layer 3
				if smash_once:
					smash()
					smash_once = false
