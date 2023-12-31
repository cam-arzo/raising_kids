extends KinematicBody2D

const SPEED := 475
var velocity := Vector2.ZERO

# stores the current held item
var item_held := 0
# stores what item can be picked up currently
var item_in_range := 0

# initial velocity added to player on shoot
const BULLET_KNOCKBACK = 600
# velocity added onto current movement velocity
var knockback_velocity := Vector2.ZERO
const KNOCKBACK_DECEL_LERP := 0.2
export var BulletResource : Resource

# how high to shoot from shoes
const SHOOT_HEIGHT := -90

func _physics_process(_delta):
	
	var input = get_input_vector()
	
	
	# smooth movement
	velocity = velocity.linear_interpolate(input * SPEED, 0.3)
	
	# apply movement
	velocity = move_and_slide(velocity + knockback_velocity)
	
	# HOLD ITEM
	if Input.is_action_pressed("pickup") and item_in_range != 0:
		hold_item(item_in_range)
	
	# SHOOT ITEM
	if Input.is_action_just_pressed("click") and item_held != 0:
		shoot()
	
	# REDUCE KNOCKBACK
	knockback_velocity = knockback_velocity.linear_interpolate(Vector2.ZERO, KNOCKBACK_DECEL_LERP)
	
	# set animation and frame
	if input == Vector2.ZERO:
		$Sprite.play("Idle")
#		run_animation("Idle")
	else:
		$Sprite.play("Walk")
	
	# set direction based on mouse relative to gun
	var gun_pos = get_local_mouse_position()-Vector2(0, $Gun.position.y)
	var right = gun_pos.x >= 0
	
	if right:
		$Sprite.flip_h = true
		$Gun.flip_h = true
		$Gun.offset.x = 140
		$Gun.position.x = 12
		$Gun.rotation = (gun_pos-Vector2($Gun.position.x, 0)).angle()
	else:
		$Sprite.flip_h = false
		$Gun.flip_h = false
		$Gun.offset.x = -140
		$Gun.position.x = -12
		$Gun.rotation = (gun_pos-Vector2($Gun.position.x, 0)).angle() + PI
	
#	# CAMERA
#	var cam_pos = position
#	var mouse_pos = get_viewport().get_mouse_position() - get_viewport().size/2
#
#	var x_limit_min = -640 + (get_viewport_rect().size.x / 2)
#	var x_limit_max = 640 - (get_viewport_rect().size.x / 2)
#
#	$Camera2D.position = cam_pos + mouse_pos
	

## set animation if its not already running
#func run_animation(animation_name):
#	if $Sprite.animation != animation_name:
#		$Sprite.animation = animation_name


func get_input_vector():
	var input : Vector2
	input.x = Input.get_axis("left", "right")
	input.y = Input.get_axis("up", "down")
	input = input.normalized()
	return input

func hold_item(item_to_hold):
	item_held = item_to_hold
	
	$HoldIcon.show()
	$HoldIcon.frame = item_held


func remove_item():
	item_held = 0
	$HoldIcon.hide()


func shoot():
	
	var mouse_angle := (get_local_mouse_position()-Vector2(0, SHOOT_HEIGHT)).angle()
	
	# add bullet
	var bullet = BulletResource.instance()
	bullet.init(item_held, position + Vector2(0, SHOOT_HEIGHT), mouse_angle)
	get_parent().add_child(bullet)
	
	# knockback player in opposite direction as shot
	knockback_velocity = Vector2.RIGHT.rotated(mouse_angle + PI) * BULLET_KNOCKBACK
	
	# remove item from held
	remove_item()
	



# system works if only one pickup is in range at one time

func _on_PickupArea_body_entered(body):
	if body.is_in_group("ItemBox"):
		item_in_range = body.item
		body.highlight()

func _on_PickupArea_body_exited(body):
	if body.is_in_group("ItemBox"):
		item_in_range = 0
		body.unhighlight()


