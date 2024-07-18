extends Resource
class_name WeaponClass

export var name_weapon:String = ""
export var damage:int = 10
export var damage_spread:int = 0
export var reload_time:float = 0.6
export var shoot_period:float = 0.1
export var endless_ammo:bool = false
export var ammo:int = 50
export var max_ammo:int = 100
export var get_ammo_per_box:int = 10

var reloading:bool = false
var pass_shoot_period:bool = true
var linked_node:Node
