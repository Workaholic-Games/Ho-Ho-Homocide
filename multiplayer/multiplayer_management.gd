extends Node
var playing_multiplayer : bool = false
var multiplayer_stats : Dictionary = {"username" = "peasant", "ip" = "host"}

func decode():
	var encoded_session_key: String = multiplayer_stats["ip"] + "=="
	var decoded_bytes: PackedByteArray = Marshalls.base64_to_raw(encoded_session_key)
	var ip_segments : Array = []
	
	for byte in decoded_bytes:
		ip_segments.append(str(byte))
	
	var orignial_ip: String = ".".join(ip_segments)
	multiplayer_stats["ip"] = orignial_ip
	print("Decoded IP: " + orignial_ip)
