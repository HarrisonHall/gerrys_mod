"""
application.py
==============
version 0.1c (websockets)
"""

from flask import (
    Flask, render_template, request, jsonify, flash,
    redirect, session, url_for
)
from flask_sockets import Sockets
from json import dumps, loads

from src import games, users


app = Flask(__name__, template_folder="./web/templates", static_folder="./web/static")
app.secret_key = b"gerry_secret_key"
sockets = Sockets(app)


@app.route("/")
def index():
    return render_template(
        "pages/index.html",
        context={}
    )

@sockets.route('/ping')
def echo_socket(ws):
    while True:
        d = {}
        message = ws.receive()
        if message is not None:
            try:
                incoming = loads(message)
                if "connect_user" == incoming["endpoint"]:
                    d = users.connect_user(incoming)
                elif "update_info" == incoming["endpoint"]:
                    print("Updating info")
                    d = games.update_info(incoming)
                elif "take_damage" == incoming["endpoint"]:
                    print("Updating damage")
                    d = games.update_damage(incoming)
                else:
                    d = games.update_game(incoming)
            except Exception as e:
                print("ERROR")
                print(e)
        else:
            print("Message was None")
        ws.send(dumps(d))

if __name__ == "__main__":
    app.run()
