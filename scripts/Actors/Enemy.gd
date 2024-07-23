extends Node2D

@onready var HealthBar = $HealthBar
@onready var WaiTimeBar = $EnemyWaitTimer

var Name
var Hp
var MaxHp
var Attack
var Skills

var attack_danger = false
var on_cursor = false
var can_be_attacked = true
var can_attack = false
var data_loaded = false
var waiting = false
var on_crossair = false 

var wait_timer

signal being_attacked(entity)
signal enemy_attacking
signal dying(entity)

func start_attacking_process():
	WaiTimeBar.visible = true
	WaiTimeBar.value = 0
	wait_timer = Timer.new()
	wait_timer.wait_time = Attack.wait_time
	wait_timer.one_shot = true
	wait_timer.timeout.connect(_on_wait_timer_timeout)
	add_child(wait_timer)
	wait_timer.start()
	waiting = true

func _ready():
	HealthBar.max_value = MaxHp
	HealthBar.value = MaxHp

func _process(delta):	
	pass

func _physics_process(delta):
	if data_loaded:
		if attack_danger and on_cursor and can_be_attacked:
			if Input.is_action_just_pressed("mouse_click"):
				print("BEING ATTACKED")
				can_attack = false
				wait_timer.set_paused(true)
				#$EnemyWaitTimer.visible = false
				being_attacked.emit(self)
				#attack_danger = false
				on_cursor = false
				$CheckSprite.visible = false
				
		if can_attack and !waiting:
			$CheckSprite.visible = false
			WaiTimeBar.visible =false
			attack_entity()
		elif !can_attack and waiting and !wait_timer.is_paused():
			WaiTimeBar.visible = true
			WaiTimeBar.step = WaiTimeBar.max_value / (wait_timer.wait_time / delta)
			WaiTimeBar.value += WaiTimeBar.step
			
func all_attack():
	print("BEING ATTACKED")
	can_attack = false
	wait_timer.set_paused(true)
	#$EnemyWaitTimer.visible = false
	being_attacked.emit(self)
	#attack_danger = false
	on_cursor = false
	$CheckSprite.visible = false

func load_data(json_path):
	print(json_path)
	var text = FileAccess.get_file_as_string(json_path)
	var temp_data = JSON.parse_string(text)
	Name = temp_data["name"]
	Hp = temp_data["hp"]
	MaxHp = temp_data["hp"]
	Skills = temp_data["skills"]
	Attack = temp_data["attack"]
	data_loaded = true
	
func get_entity_name():
	return Name

func get_skills():
	return Skills
	
func get_hp():
	return Hp

func get_max_hp():
	return MaxHp
	
func deal_dmg():
	pass
	
func get_dmg(attack):
	Hp -= attack.dmg
	HealthBar.value = Hp
	#-----ten fragment będzie później po sygnale zakończenia animacji ataku--------#
	wait_timer.set_paused(false)
	attack_danger = false
	if Hp <= 0:
		dying.emit(self)
	

func _on_wait_timer_timeout():
	can_attack = true
	waiting = false

func attack_entity():
	var can_be_attacked = get_parent().get_can_be_attack_entities()
	if len(can_be_attacked) > 0:
		$EnemyWaitTimer.visible = false
		var random = RandomNumberGenerator.new()
		var attacked_entity =  can_be_attacked[random.randi_range(0, len(can_be_attacked) -1)]
		enemy_attacking.emit(attacked_entity, Attack)
		can_attack = false
		attack_danger = false
		wait_timer.queue_free()
		start_attacking_process()
	
func _on_area_2d_mouse_entered():
	if attack_danger:
		on_cursor = true
		$CheckSprite.visible = true


func _on_area_2d_mouse_exited():
	if attack_danger:
		on_cursor = false
		$CheckSprite.visible = false


func _on_area_2d_body_entered(body):
	if body.name == "RangeSKillCheck":
		print("ON CROSSARI")
		on_crossair = true


func _on_area_2d_body_exited(body):
	if body.name == "RangeSKillCheck":
		on_crossair = false
