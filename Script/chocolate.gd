extends Area3D

@onready var signalManager = get_parent().get_parent().get_node("SignalManager")
var able_to_take_chocolate: bool = false

func ableToTakeChocolate():
	able_to_take_chocolate = true

func _ready():
	signalManager.connect("all_object_broken", ableToTakeChocolate)

func _on_body_entered(body: Node3D) -> void:
	signalManager.disconnect("all_object_broken", ableToTakeChocolate)
	if able_to_take_chocolate:
		print("You took the chocolate!")
