extends Node

var url = "ws://gerrys-mod-demo.herokuapp.com/ping"
var client_id = -1
var client_name = 0

# Emits when new data is received, has obj (dict) parameter
signal new_data


# Our WebSocketClient instance
var client = WebSocketClient.new()

func _ready():
	# Initiate connection to the given URL.
	#connect_to_server()
	pass

var is_connected = false
func connect_to_server():
	# Initiate connection to the given URL.
	var err = client.connect_to_url(url)
	if err != OK:
		print("Unable to connect")
		#set_process(false)
	else:
		is_connected = true

func _closed(was_clean = false):
	is_connected = false
	if was_clean:
		print("Websocket closed")
	if not was_clean:
		print("Forced disconnect from server")
	#set_process(false)

func _connected(proto = ""):
	is_connected = true
	print("Connected to server: " + url)

func _process(delta):
	if is_connected:
		client.poll()

func request(endpoint, data):
	data["endpoint"] = endpoint
	var query = JSON.print(data)
	client.get_peer(1).put_packet(query.to_utf8())

func received_data():
	var raw = client.get_peer(1).get_packet().get_string_from_utf8()
	var res = JSON.parse(raw)
	var obj = res.result
	emit_signal("new_data", obj)

func change_server_url(new_url):
	url = new_url
	client = WebSocketClient.new()
	client.connect("connection_closed", self, "_closed")
	client.connect("connection_error", self, "_closed")
	client.connect("connection_established", self, "_connected")
	client.connect("data_received", self, "received_data")
	#client.encode_buffer_max_size = 8388608 * 4
	#connect_to_server()






