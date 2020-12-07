"""
users.py
========
handle adding and removing users
"""

import datetime
from json import load
from time import time as timestamp


next_id = 0
current_users = {}
current_objects = {}
current_settings = {
    "map": "DebugArea"
}
last_player = "No player has joined yet"
kill_queue = []
DISCONNECT_TIME = 5

users = {}
with open("data/users.json", "r") as jsonfile:
    users = load(jsonfile)

def add_user(username):
    global next_id
    global last_player
    new_id = next_id
    next_id += 1

    current_users[username] = {
        "id": new_id,
        "player": {
            "position": [0, 0, 0],
            "momentum": [0, 0, 0],
            "rotation": [0, 0, 0],
            "model": "seagal",
            "vrot": 0,
            "is_crouching": False,
            "slide_time": 0,
            "data": {}
        },
        "updates": {
            "players": {}
        },
        "just_joined": True,
        "last_time": datetime.datetime.now(),
        "last_given_timestamp": 0,
    }
    last_player = username
    return new_id

def connect_user(obj):
    """
    See if a user can be connected.
    """
    d = {}
    d["login_status"] = False
    if password_correct(
            obj.get("username", ""),
            obj.get("password", "")
    ):
        d["login_status"] = True
        d["username"] = obj["username"]
        pid = add_user(obj["username"])
        d["updates"] = {
            "new_arena": "DebugArea"
        }
    return d

def user_pinged(username):
    if username == "":
        return
    if username not in current_users:
        return
    current_users[username]["last_time"] = datetime.datetime.now()

def password_correct(username, password):
    if username in users:
        return users[username]["password"] == password
    return False

def zero_update(username):
    current_users[username]["updates"]["players"] = {}

def remove_users():
    to_remove = []
    current_time = datetime.datetime.now()
    for user in current_users:
        last_time = current_users[user]["last_time"]
        if (current_time - last_time).total_seconds() > DISCONNECT_TIME:
            to_remove.append(user)
    for user in to_remove:
        del current_users[user]
    return to_remove

def just_joined(username):
    jj = current_users[username]["just_joined"]
    current_users[username]["just_joined"] = False
    return jj

def add_users(username, d):
    if "players" not in d:
        d["players"] = {}
    for user in (set(current_users) - {username}):
        d["players"][user] = current_users[user]["player"]

def timestamp_valid(username, new_timestamp):
    if new_timestamp > current_users[username]["last_given_timestamp"]:
        current_users[username]["last_given_timestamp"] = new_timestamp
        return True
    return False

def get_objects(username):
    return current_objects

def update_object(username, obj, values, new_timestamp):
    old_obj = get_objects(username)[obj]
    old_obj["position"] = values.get("position", old_obj["position"])
    old_obj["momentum"] = values.get("momentum", old_obj["momentum"])
    old_obj["rotation"] = values.get("rotation", old_obj["rotation"])
    old_obj["timestamp"] = timestamp()
    old_obj["timestamps"][username] = new_timestamp
    old_obj["last_update_from"] = username
    old_obj["data"] = values.get("data", old_obj["data"])
    old_obj["kill"] = values.get("kill", old_obj["kill"])

def remove_object(username, obj):
    del current_objects[obj]

def add_object(username, obj, values):
    print("Creating",obj)
    current_objects[obj] = {
        "position": values.get("position", [0, 0, 0]),
        "momentum": values.get("momentum", [0, 0, 0]),
        "rotation": values.get("rotation", [0, 0, 0]),
        "timestamp": timestamp(),
        "timestamps": {
            username: values.get("timestamp", -1),
        },
        "last_update_from": username,
        "type": values["type"],
        "data": values.get("data", {}),
        "kill": False,
    }

def object_update_valid(username, obj, new_timestamp):
    return (
        get_objects(username)[obj]["timestamps"].get(username, -1) < new_timestamp
    )

def current_player_count():
    return len(current_users)

def last_player_joined():
    return last_player

def get_settings(username):
    return current_settings
