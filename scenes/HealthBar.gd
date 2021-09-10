extends CanvasLayer

enum BarState {Healthy, Damaged, Gone}

# not possible to store object references in dicts? Got null error. Need to store string name and get_node(name)
var health_bar = {0: ["Bar1", BarState.Healthy], 1: ["Bar2",  BarState.Healthy], 2: ["Bar3", BarState.Healthy], 3: ["Bar4",  BarState.Healthy]}
var current_bar: int = 3


func _on_Player_player_hit(hit_points: int, max_hitpoints: int):
	print(hit_points, " left out of ", max_hitpoints)
	match health_bar[current_bar][1]:
		BarState.Healthy:
			var bar = health_bar[current_bar][0]
			get_node(bar).set_modulate(Color(0.8, 0.2, 0.2, 0.8))
			health_bar[current_bar][1] = BarState.Damaged
		BarState.Damaged:
			var bar = health_bar[current_bar][0]
			get_node(bar).visible = false
			health_bar[current_bar][1] = BarState.Gone
			current_bar -= 1
		BarState.Gone:
			print("Error: BarState index should be lower")
			pass

	
