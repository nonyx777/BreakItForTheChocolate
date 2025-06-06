extends Node3D

func _input(event: InputEvent) -> void:
	# Check if the event is a key press
	var key_event = event as InputEventKey
	
	# Reference to the STM instance (ensure this matches the name in your scene tree)
	var stm_instance = $RigidBody3D/STMCachedInstance3D
	
	# Return if STM instance or key event is invalid, or the key is not SPACE
	if !stm_instance or !key_event or key_event.keycode != KEY_SPACE:
		return
	
	# Break the mesh when SPACE is pressed
	if key_event.is_pressed():
		stm_instance.smash_the_mesh()
	
	# Apply an "explode" impulse to each fragment/chunk when SPACE is released
	elif key_event.is_released():

		# Define a callback to apply an impulse to a rigid body chunk
		var explode_callback = func(rb: RigidBody3D, _from):
			rb.apply_impulse(-rb.global_position.normalized() * Vector3(1, -1, 1) * 3.0)
		
		# Apply the callback to each chunk of the mesh
		stm_instance.chunks_iterate(explode_callback)
