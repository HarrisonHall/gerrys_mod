extends Node


var url = "https://gerrys-mod-demo.herokuapp.com/"
var client_id = -1
var client_name = 0
onready var requests = $requests

# Called when the node enters the scene tree for the first time.
func _ready():
	$requests.connect("request_completed", self, "received_data")

func _process(delta):
	pass

func request(endpoint, data):
	# Convert data to json string:
	var query = JSON.print(data)
	# Add 'Content-Type' header:
	var headers = ["Content-Type: application/json"]
	$requests.request(url + endpoint, headers, true, HTTPClient.METHOD_POST, query)

func emit(endpoint):
	$requests.request(url + endpoint)

func received_data(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())

func log_in(username):
	return false
