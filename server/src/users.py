"""
users.py
========
handle adding and removing users
"""

import datetime
from json import load


next_id = 0
current_users = {}
DISCONNECT_TIME = 5

users = {}
with open("data/users.json", "r") as jsonfile:
    users = load(jsonfile)

def add_user(username):
    global next_id
    new_id = next_id
    next_id += 1

    current_users[username] = {
        "id": new_id,
        "player": {
            "position": [0, 0, 0],
            "momentum": [0, 0, 0],
            "rotation": [0, 0, 0],
        },
        "updates": {
            "players": {}
        },
        "just_joined": True,
        "last_time": datetime.datetime.now(),
        "last_given_timestamp": 0,
    }
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
    current_users[username]["last_time"] = datetime.datetime.now()

def password_correct(username, password):
    if username in users:
        return users[username]["password"] == password
    return False

def zero_update(username):
    current_users[username]["updates"]["players"] = {}

def remove_users():
    return []
    to_remove = []
    current_time = datetime.datetime.now()
    for user in current_users:
        last_time = current_users[user]["last_time"]
        if (current_time - last_time).total_seconds() > DISCONNECT_TIME:
            to_remove.append(user)
    return to_remove

def just_joined(username):
    jj = current_users[username]["just_joined"]
    current_users[username]["just_joined"] = False
    return jj

def add_users(username, d):
    if "players" not in d:
        d["players"] = {}
    for user in (set(current_users) - {username}):
    #for user in current_users:
        d["players"][user] = current_users[user]["player"]

def timestamp_valid(username, new_timestamp):
    if new_timestamp > current_users[username]["last_given_timestamp"]:
        current_users[username]["last_given_timestamp"] = new_timestamp
        return True
    return False