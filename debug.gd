extends Node2D

func _ready() -> void:
	print("Multiplayer encryption test:")
	var test_ip = "host"
	
	for method in MultiplayerManagement.obfuscation_type.values():
		MultiplayerManagement.active_method = method
		var method_name = MultiplayerManagement.obfuscation_type.keys()[method]
		var encoded = MultiplayerManagement.encode(test_ip)
		var decoded = MultiplayerManagement.decode(encoded)
		print("[%s Method]" % method_name)
		print("Original: ", test_ip)
		print("Encoded: ", encoded)
		print("Decoded: ", decoded)
		
		if test_ip == decoded:
			print("Decode Success: ", "[%s method]" % method_name)
		else:
			print("Decode Failed: ", "[%s method]" % method_name)
