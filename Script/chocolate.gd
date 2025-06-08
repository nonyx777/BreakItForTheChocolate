extends Area3D

@onready var signalManager = get_parent().get_parent().get_node("SignalManager")
@onready var chocolateMesh = $Chocolate
@onready var winnerLabel: Label = get_parent().get_parent().get_node("Label")

var able_to_take_chocolate: bool = false

func ableToTakeChocolate():
	able_to_take_chocolate = true

func _ready():
	signalManager.connect("all_object_broken", ableToTakeChocolate)
	winnerLabel.visible = false

func _on_body_entered(body: Node3D) -> void:
	if able_to_take_chocolate:
		signalManager.disconnect("all_object_broken", ableToTakeChocolate)
		winnerLabel.visible = true
		chocolateMesh.queue_free()
		print("You took the chocolate!")
