extends Node

var playing_multiplayer : bool = false
var multiplayer_stats : Dictionary = {"username" = "peasant", "ip" = "host"}
var public_ip : String = ""
var upnp: UPNP = null
var active_method: obfuscation_type = obfuscation_type.BASE64

const port = 9998

const SECRET_KEY: String = "BulbasaurSmells1" #16 ,24, 32

enum obfuscation_type {NONE, XOR, HEX, AES, BASE64}

func upnp_setup():
	upnp = UPNP.new()
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Discover Failed! Error %s" % discover_result)
	
	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
		"UPNP Invalid Gateway!")
	
	var map_result = upnp.add_port_mapping(port)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Port Mapping Failed! Error %s" % map_result)
	var pool = obfuscation_type.values()
	pool.erase(obfuscation_type.NONE)
	active_method = pool.pick_random() as obfuscation_type
	print(active_method)
	var encoded = MultiplayerManagement.encode(multiplayer_stats["ip"])
	print("Encoded: ", encoded)
	print("Success!")

func encode(ip: String) -> String:
	var raw_bytes = ip_to_bytes(ip)
	var prefix = ""
	var encoded_body = ""
	
	
	match active_method:
		obfuscation_type.NONE:
			prefix = "N"
			encoded_body = ip
		obfuscation_type.XOR:
			prefix = "X"
			encoded_body = bytes_to_hex(xor_bytes(raw_bytes))
		obfuscation_type.HEX:
			prefix = "H"
			encoded_body = bytes_to_hex(raw_bytes)
		obfuscation_type.AES:
			prefix = "A"
			var aes = AESContext.new()
			var padded_bytes = raw_bytes.duplicate()
			while padded_bytes.size() < 16:
				padded_bytes.append(0)
			aes.start(AESContext.MODE_ECB_ENCRYPT, SECRET_KEY.to_utf8_buffer())
			var encrypted = aes.update(padded_bytes)
			aes.finish()
			encoded_body = Marshalls.raw_to_base64(encrypted).replace("=", "")
			#encoded_body = bytes_to_hex(encrypted)
		obfuscation_type.BASE64:
			prefix = "B"
			var encoded_session_key: String = Marshalls.raw_to_base64(raw_bytes)
			encoded_session_key = encoded_session_key.replace("=", "")
			encoded_body = encoded_session_key
			
	return prefix + encoded_body
	
func decode(encoded_str: String) -> String:
	if encoded_str.is_empty(): return ""
	var identifier = encoded_str.substr(0, 1)
	var encoded_body = encoded_str.substr(1)
	match identifier:
		"N": active_method = obfuscation_type.NONE
		"X": active_method = obfuscation_type.XOR
		"H": active_method = obfuscation_type.HEX
		"B": active_method = obfuscation_type.BASE64
		"A": active_method = obfuscation_type.AES
		_: 
			print("Unkown Identifier")
			return ""
		
	match active_method:
		obfuscation_type.NONE:
			return encoded_body
			
		obfuscation_type.HEX:
			var input_bytes = hex_to_bytes(encoded_body)
			return bytes_to_ip(input_bytes)
			
		obfuscation_type.XOR:
			var input_bytes = hex_to_bytes(encoded_body)
			var decrypted_bytes = xor_bytes(input_bytes)
			return bytes_to_ip(decrypted_bytes)
			
		obfuscation_type.AES:
			var base64_str = encoded_body + "=="
			var input_bytes = Marshalls.base64_to_raw(base64_str)
			#var input_bytes = hex_to_bytes(encoded_body)
			var aes = AESContext.new()
			aes.start(AESContext.MODE_ECB_DECRYPT, SECRET_KEY.to_utf8_buffer())
			var decrypted = aes.update(input_bytes)
			aes.finish()
			var ip_bytes = decrypted.slice(0, 4)
			return bytes_to_ip(ip_bytes)
			
		obfuscation_type.BASE64:
			var base64_str = encoded_body + "=="
			var decoded_bytes: PackedByteArray = Marshalls.base64_to_raw(base64_str)
			return bytes_to_ip(decoded_bytes)
			
	return ""

func ip_to_bytes(ip: String) -> PackedByteArray:
	var segments = ip.split(".")
	var bytes = PackedByteArray()
	for segment in segments:
		bytes.append(segment.to_int())
	return bytes

func bytes_to_ip(bytes: PackedByteArray) -> String:
	var segments: Array = []
	for byte in bytes:
		segments.append(str(byte))
	return ".".join(segments)

func xor_bytes(data: PackedByteArray) -> PackedByteArray:
	var key_bytes = SECRET_KEY.to_utf8_buffer()
	var result = PackedByteArray()
	for i in range(data.size()):
		result.append(data[i] ^ key_bytes[i % key_bytes.size()])
	return result

func bytes_to_hex(bytes: PackedByteArray) -> String:
	var hex_str = ""
	for byte in bytes:
		hex_str += "%02x" % byte
	return hex_str

func hex_to_bytes(hex_string: String) -> PackedByteArray:
	var bytes = PackedByteArray()
	for i in range(0, hex_string.length(), 2):
		var byte_hex = hex_string.substr(i, 2)
		bytes.append(byte_hex.hex_to_int())
	return bytes
