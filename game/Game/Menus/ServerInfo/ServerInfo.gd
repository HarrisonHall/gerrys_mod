extends Control


var max_timer = 15
var timer = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	$HTTPRequest.connect("request_completed", self, "update_main_page")


func _process(delta):
	timer -= delta
	if timer <= 0:
		timer = max_timer
		var query = JSON.print({})
		var headers = ["Content-Type: application/json"]
		$HTTPRequest.request(
			"https://gerrys-mod-demo.herokuapp.com/info",
			headers, true, HTTPClient.METHOD_POST, query
		)

func update_main_page(result, response_code, headers, body):
	var message = ""
	#print(body.get_string_from_utf8())
	var json = JSON.parse(body.get_string_from_utf8()).result
	$PageContainer/MainPage.text = ""
	for key in json:
		var value = json[key]
		$PageContainer/MainPage.text += str(key) + ": " + str(value) + "\n"
