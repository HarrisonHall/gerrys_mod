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
import traceback

from src import game_handler


app = Flask(__name__, template_folder="./web/templates", static_folder="./web/static")
app.secret_key = b"gerry_secret_key"
sockets = Sockets(app)


@app.route("/")
def index():
    return render_template(
        "pages/index.html",
        context={}
    )

@app.route("/info", methods=["POST"])
def info():
    return jsonify({
        "Current Player Count": game_handler.current_player_count(),
        "Last Player Joined": game_handler.last_player_joined(),
    })

@sockets.route('/ping')
def echo_socket(ws):
    while True:
        try:
            d = {}
            message = ws.receive()
            if message is None:
                print("Message was None")
                ws.send(dumps(d))
            else:
                incoming = loads(message)

                if game_handler.base_object_valid(incoming):
                    d = game_handler.update(incoming)
                    game_handler.user_pinged(incoming.get("username"), incoming.get("timestamp"))
                elif game_handler.can_add_user(incoming):
                    print("ADDED USER")
                    d = game_handler.add_user(incoming)
                else:
                    print("INVALID!")
                    d = game_handler.invalid_packet_response(incoming)
                ws.send(dumps(d))
        except Exception as e:
            print("Disconnected user:", e)
            traceback.print_exc()
            ws.close()
            return

if __name__ == "__main__":
    app.run()
