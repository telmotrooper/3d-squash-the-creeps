extends Enemy

export var patrolling_speed = 9

enum {
  PATROLLING,
  ALERT
}

var state = PATROLLING


func _process(delta):
  match state:
    PATROLLING:
      if get_parent() is PathFollow:
        get_parent().set_offset(get_parent().get_offset() + patrolling_speed * delta)
    ALERT:
      if get_parent() is PathFollow:
        get_parent().rotation = Vector3.ZERO
      if is_instance_valid(GameState.Player):
        # rotation is the problem
        initiliaze(self.transform.origin, GameState.Player.transform.origin, false)

func _on_VisibilityNotifier_screen_exited():
  pass # Prevent "queue_free()" from parent.

func _on_PrismArea_body_entered(body):
  if body is Player:
    state = ALERT
