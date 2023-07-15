extends RigidBody3D
class_name PlayerBall

# Reference: https://youtu.be/G6OGM4fdF3M

var initial_position: Vector3
var initial_camera_position: Vector3
var force = 40

func _ready() -> void:
  initial_position = global_transform.origin

func _physics_process(delta: float) -> void:
  # Make camera follow player ball.
  %CameraPivot.position = initial_position + position
  
  # Get direction vector based checked input.
  var direction = Vector3(
    Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
    0,
    Input.get_action_strength("move_back") - Input.get_action_strength("move_forward"))
  
  if direction != Vector3.ZERO:
    # Rotate direction based checked camera.
    var horizontal_rotation = %CameraPivot/Horizontal.global_transform.basis.get_euler().y
    direction = direction.rotated(Vector3.UP, horizontal_rotation).normalized()
    # Move player ball according to input and camera direction.
    angular_velocity.x += direction.z * force * delta
    angular_velocity.z -= direction.x * force * delta


func move_to_last_safe_position() -> void:
  position = Vector3.ZERO # Start of the map.
  sleeping = true # Make ball stop moving.
