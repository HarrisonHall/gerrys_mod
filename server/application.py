"""
application.py
==============
version 0.1a
"""

from flask import (
    Flask, render_template, request, jsonify, flash,
    redirect, session, url_for
)
from flask_sockets import Sockets
from flask_socketio import (
    SocketIO, join_room, leave_room, emit, rooms
)
from copy import deepcopy
from json import dumps, loads
from time import time as timestamp

from src import games as login



app = Flask(__name__, template_folder="./web/templates", static_folder="./web/static")
app.secret_key = b"gerry_secret_key"
sockets = Sockets(app)


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
    username = request.json.get("username", "")
    new_timestamp = request.json.get("timestamp", -1)
    if new_timestamp < login.current_users[username]["last_given_timestamp"]:
        return jsonify({})
    login.current_users[username]["last_given_timestamp"] = new_timestamp
    
    print(f"{username}: ", end="")
    
    # Update player positions
    players = request.json.get("players", [])
    if players != []:
        print("players:| ", end="")
    # update the rest of the players
    for player in players:
        print(f"{player},", end="")
        data = request.json["players"][player]
        pos = data.get("position", login.current_users[player]["player"]["position"])
        mom = data.get("momentum", login.current_users[player]["player"]["momentum"])
        rot = data.get("rotation", login.current_users[player]["player"]["rotation"])
        login.current_users[player]["player"]["position"] = pos
        login.current_users[player]["player"]["momentum"] = mom
        login.current_users[player]["player"]["rotation"] = rot
        for user in (set(login.current_users) - set(username)):
            login.current_users[user]["updates"]["players"][player] = login.current_users[player]["player"]
            
    # TODO update other stuff
    
    update = deepcopy(login.current_users[username]["updates"])
    if login.current_users[username]["just_joined"]:
        login.current_users[username]["just_joined"] = False
        for user in (set(login.current_users) - set(username)):
            update["players"][user] = login.current_users[user]["player"]

    # Zero the update
    login.current_users[username]["updates"]["players"] = {}
    
    print()
    d = {
        "updates": update,
        "timestamp": timestamp()
    }
    return jsonify(d)

def connect_user_s(obj):
    d = {}
    d["login_status"] = False
    if login.password_correct(
            obj.get("username", ""),
            obj.get("password", "")
    ):
        d["login_status"] = True
        d["username"] = obj["username"]
        pid = login.add_user(obj["username"])
        d["updates"] = {
            "new_arena": "DebugArea"
        }
        
    return d

def update_player_s(obj):
    username = obj.get("username", "")
    new_timestamp = obj.get("timestamp", -1)
    if new_timestamp < login.current_users[username]["last_given_timestamp"]:
        return jsonify({})
    login.current_users[username]["last_given_timestamp"] = new_timestamp
    
    print(f"{username}: ", end="")
    
    # Update player positions
    players = obj.get("players", [])
    if players != []:
        print("players:| ", end="")
    # update the rest of the players
    for player in players:
        print(f"{player},", end="")
        data = obj["players"][player]
        pos = data.get("position", login.current_users[player]["player"]["position"])
        mom = data.get("momentum", login.current_users[player]["player"]["momentum"])
        rot = data.get("rotation", login.current_users[player]["player"]["rotation"])
        login.current_users[player]["player"]["position"] = pos
        login.current_users[player]["player"]["momentum"] = mom
        login.current_users[player]["player"]["rotation"] = rot
        for user in (set(login.current_users) - set(username)):
            login.current_users[user]["updates"]["players"][player] = login.current_users[player]["player"]
            
    # TODO update other stuff
    
    update = deepcopy(login.current_users[username]["updates"])
    if login.current_users[username]["just_joined"]:
        login.current_users[username]["just_joined"] = False
        for user in (set(login.current_users) - set(username)):
            update["players"][user] = login.current_users[user]["player"]

    # Zero the update
    login.current_users[username]["updates"]["players"] = {}
    
    print()
    d = {
        "updates": update,
        "timestamp": timestamp()
    }
    return d

@app.route("/test")
def test():
    return jsonify({
        "test": "success"
    })

@sockets.route('/ping')
def echo_socket(ws):
    while True:
        d = {}
        message = ws.receive()
        if message is not None:
            print(message)
            incoming = loads(message)
            #print(incoming)
            if "connect_user" == incoming["endpoint"]:
                d = connect_user_s(incoming)
            else:
                d = update_player_s(incoming)
        else:
            print("Message was None")
        ws.send(dumps(d))

if __name__ == "__main__":
    #socketio.run(app, debug=True)
    
    app.run()

    #from gevent import pywsgi
    #from geventwebsocket.handler import WebSocketHandler
    #server = pywsgi.WSGIServer(('http://127.0.0.1', 5000), app, handler_class=WebSocketHandler)
    #server.serve_forever()
