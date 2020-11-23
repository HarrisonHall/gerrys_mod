extends Node


#var websocket_url = "https://gerrys-mod-demo.herokuapp.com/"
#var url = "ws://127.0.0.1:8000/ping"
var url = "ws://gerrys-mod-demo.herokuapp.com/ping"
var client_id = -1
var client_name = 0

# Emits when new data is received, has obj (dict) parameter
signal new_data


# Our WebSocketClient instance
var _client = WebSocketClient.new()

func _ready():
	# Initiate connection to the given URL.
	connect_to_server()

var is_connected = false
func connect_to_server():
	# Initiate connection to the given URL.
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	_client.connect("data_received", self, "received_data")
	var err = _client.connect_to_url(url)
	if err != OK:
		print("Unable to connect")
		set_process(false)
	else:
		is_connected = true

func _closed(was_clean = false):
	# was_clean will tell you if the disconnection was correctly notified
	# by the remote peer before closing the socket.
	print("Closed, clean: ", was_clean)
	set_process(false)

func _connected(proto = ""):
	print("Connected to server with protocol: ", proto)

func _process(delta):
	_client.poll()

func request(endpoint, data):
	data["endpoint"] = endpoint
	var query = JSON.print(data)
	_client.get_peer(1).put_packet(query.to_utf8())

func received_data():
	var raw = _client.get_peer(1).get_packet().get_string_from_utf8()
	var res = JSON.parse(raw)
	var obj = res.result
	emit_signal("new_data", obj)

func change_server(new_url):
	url = new_url
	#_client.queue_free()
	_client = WebSocketClient.new()
	connect_to_server()






