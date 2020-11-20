"""
application.py
==============
"""

from flask import (
    Flask, render_template, request, jsonify, flash,
    redirect, session, url_for
)
from flask_socketio import (
    SocketIO, join_room, leave_room, emit, rooms
)

from src import login


app = Flask(__name__, template_folder="./web/templates", static_folder="./web/static")
app.secret_key = b"gerry_secret_key"


@app.route("/")
def index():
    return render_template(
        "pages/index.html",
        context={}
    )

@app.route("/connect_user", methods=["POST"])
def connect_user():
    print(request.json)
    d = {}
    d["login_status"] = False
    if login.password_correct(
        request.json.get("username", ""),
        request.json.get("password", "")
    ):
        d["login_status"] = True
        d["username"] = request.json["username"]
        pid = login.add_user(request.json["username"])
        d["updates"] = {
            "new_arena": "DebugArea"
        }
        
    return jsonify(d)

@app.route("/update_player", methods=["POST"])
def update_player():
    print(request.json)
    username = request.json.get("username", "")
    # Update player positions
    players = request.json.get("players", [])
    for player in players:
        data = request.json["players"][player]
        pos = data.get("position", login.current_users[player]["player"]["position"])
        mom = data.get("momentum", login.current_users[player]["player"]["momentum"])
        login.current_users[player]["player"]["position"] = pos
        login.current_users[player]["player"]["momentum"] = mom
        for user in login.current_users:
            if user != username:
                login.current_users[user]["update"]["players"][username] = login.current_users[player]["player"]
    update = login.current_users[user]["update"]
    login.current_users[user]["update"] = {}
    return jsonify(update)

@app.route("/test")
def test():
    return jsonify({
        "test": "success"
    })

if __name__ == "__main__":
    #socketio.run(app, debug=True)
    app.run()
