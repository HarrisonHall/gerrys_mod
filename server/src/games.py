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
        print("INVALID TIMESTAMP", data.current_users[username]["last_given_timestamp"], new_timestamp)
        return {}
    
    # update the rest of the players
    for player in players:
        update_player(username, player, obj["players"][player])
            
    # TODO update other stuff

    # TODO see if any other players need removing
    to_remove = data.remove_users()

    # Send update to player
    update = deepcopy(data.current_users[username]["updates"])

    # If player just joined, send them all updates
    if data.just_joined(username):
        data.add_users(username, update)

    # Zero the update
    data.zero_update(username)
    
    d = {
        "updates": update,
        "objects": data.get_objects(username),
        "timestamp": timestamp(),
        "to_remove": to_remove
    }
    return d

def update_info(obj):
    # Get variables
    username = obj.get("username", "")
    data.user_pinged(username)
    new_timestamp = obj.get("timestamp", -1)

    updates = obj.get("update", {})

    for person in updates.get("people", {}):
        if "model" in updates["people"][person]:
            data.current_users[username]["player"]["model"] = updates["people"][person]["model"]

    objects = updates.get("objects", {})
    for obj in objects:
        if obj in data.get_objects(username):
            # Check timestamp before updating
            if data.object_update_valid(username, obj, new_timestamp):
                print("updating ", obj)
                data.update_object(username, obj, objects[obj], new_timestamp)
                if objects[obj].get("kill", False):
                    data.remove_object(username, obj)
            else:
                print("Update invalid: ", new_timestamp)
        else:
            data.add_object(username, obj, objects[obj])

    return {}

def update_player(username, player, data):
    """
    Update player info
    """
    pos = data.get("position", data.current_users[player]["player"]["position"])
    mom = data.get("momentum", data.current_users[player]["player"]["momentum"])
    rot = data.get("rotation", data.current_users[player]["player"]["rotation"])
    vrot = data.get("vrot", data.current_users[player]["player"]["vrot"])
    is_crouching = data.get("is_crouching", data.current_users[player]["player"]["is_crouching"])
    slide_time = data.get("slide_time", data.current_users[player]["player"]["slide_time"])
    dat = data.get("data", data.current_users[player]["player"]["data"])
    
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
        
