"""
games.py
========
Handle updating game info.
"""

from copy import deepcopy
from time import time as timestamp

from . import data


def update_game(obj):
    # Get variables
    username = obj.get("username", "")
    data.user_pinged(username)
    players = obj.get("players", [])
    new_timestamp = obj.get("timestamp", -1)

    # Make sure user can submit update
    if not data.timestamp_valid(username, new_timestamp):
        return {}

    if not data.settings_valid(obj.get("settings", {})):
        d = {
            "settings": data.get_settings(username),
            "timestamp": timestamp(),
        }
        return d
    
    # update the rest of the players
    for player in players:
        update_player(username, player, obj["players"][player])
            
    # Send game update to player
    update = {
        "players": {
            user: data.current_users[user]["player"] for user in data.current_users if user != username
        }
    }

    d = {
        "updates": update,
        "objects": data.get_objects(username),
        "timestamp": timestamp(),
        "settings": data.get_settings(username)
    }
    return d

def update_info(obj):
    # Get variables
    username = obj.get("username", "")
    data.user_pinged(username)
    new_timestamp = obj.get("timestamp", -1)

    updates = obj.get("update", {})

    if not data.settings_valid(obj.get("settings", {})):
        d = {
            "settings": data.get_settings(username),
            "timestamp": timestamp(),
        }
        return d

    for person in updates.get("people", {}):
        if "model" in updates["people"][person]:
            data.current_users[username]["player"]["model"] = updates["people"][person]["model"]

    objects = updates.get("objects", {})
    for obj in objects:
        if obj in data.get_objects(username):
            # Check timestamp before updating
            if data.object_update_valid(username, obj, new_timestamp):
                data.update_object(username, obj, objects[obj], new_timestamp)
                if objects[obj].get("kill", False):
                    data.remove_object(username, obj)
        else:
            data.add_object(username, obj, objects[obj])

    return {}

def update_player(username, player, obj):
    """
    Update player info
    """
    pos = obj.get("position", data.current_users[player]["player"]["position"])
    mom = obj.get("momentum", data.current_users[player]["player"]["momentum"])
    rot = obj.get("rotation", data.current_users[player]["player"]["rotation"])
    vrot = obj.get("vrot", data.current_users[player]["player"]["vrot"])
    is_crouching = obj.get("is_crouching", data.current_users[player]["player"]["is_crouching"])
    slide_time = obj.get("slide_time", data.current_users[player]["player"]["slide_time"])
    dat = obj.get("data", data.current_users[player]["player"]["data"])
    
    data.current_users[player]["player"]["position"] = pos
    data.current_users[player]["player"]["momentum"] = mom
    data.current_users[player]["player"]["rotation"] = rot
    data.current_users[player]["player"]["vrot"] = vrot
    data.current_users[player]["player"]["is_crouching"] = is_crouching
    data.current_users[player]["player"]["slide_time"] = slide_time
    data.current_users[player]["player"]["data"] = dat
    
    for user in (set(data.current_users) - {username}):
        data.current_users[user]["updates"]["players"][player] = data.current_users[player]["player"]
    return True

def update_damage(obj):
    for user, info in obj["players"].items():
        data.current_users[user]["updates"]["players"][user] = {
            "damage": info["damage"]
        }
    return {}

def update_server_settings(obj):
    username = obj.get("username", "")
    if username == "":
        return {}
    if "map" in obj:
        if obj["map"] != data.current_settings["map"]:
            data.current_settings["map"] = obj["map"]
            data.current_objects = {}
            for user in data.current_users:
                data.current_users[user]["player"] = data.reset_player()
            data.update_server_version()
    return {
        "settings": data.get_settings(username)
    }
