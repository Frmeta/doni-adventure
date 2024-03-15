extends Node2D

var num_players = 8

var available = []


export var soundNames: PoolStringArray = []
export (Array, float) var soundVolumes


func _ready():
	for i in num_players:
		# create new audioStreamPlayer
		var p = AudioStreamPlayer.new()
		add_child(p)
		available.append(p)
		p.connect("finished", self, "_on_stream_finished", [p])


func _on_stream_finished(stream):
	available.append(stream)


func play(sound_name):
	var mp3 = ResourceLoader.exists("res://sound/" + sound_name + ".mp3")
	var wav = ResourceLoader.exists("res://sound/" + sound_name + ".wav")
	
	if not mp3 and not wav:
		print("sound not found")
		return
	
	var stream;
	if mp3:
		stream = load("res://sound/" + sound_name + ".mp3")
	else:
		stream = load("res://sound/" + sound_name + ".wav")
	
	if available.empty():
		
		# create new audioStreamPlayer
		var p = AudioStreamPlayer.new()
		add_child(p)
		available.append(p)
		p.connect("finished", self, "_on_stream_finished", [p])
		
	# play sound
	available[0].stream = stream
	available[0].play()
	if sound_name in soundNames:
		available[0].volume_db = soundVolumes[soundNames.find(sound_name)]
	else:
		available[0].volume_db = 0
	available.pop_front()

	
func stop_all_sound():
	for i in get_children():
		if not i in available:
			i.stop()
			available.append(i)

