"""
games.py
========
Handle updating game info.
"""

from . import users


from copy import deepcopy
from time import time as timestamp

def update_game(obj):
    # Get variables
    username = obj.get("username", "")
    users.user_pinged(username)
    players = obj.get("players", [])
    new_timestamp = obj.get("timestamp", -1)

    # Make sure user can submit update
    
    if not users.timestamp_valid(username, new_timestamp):
        return {}
    
    # update the rest of the players
    for player in players:
        update_player(username, player, obj["players"][player])
            
    # TODO update other stuff

    # TODO see if any other players need removing
    to_remove = users.remove_users()

    # Send update to player
    update = deepcopy(users.current_users[username]["updates"])

    # If player just joined, send them all updates
    if users.just_joined(username):
        users.add_users(username, update)

    # Zero the update
    users.zero_update(username)
    
    d = {
        "updates": update,
        "timestamp": timestamp(),
        "to_remove": to_remove
    }
    return d

def update_player(username, player, data):
    """
    Update player info
    """
    pos = data.get("position", users.current_users[player]["player"]["position"])
    mom = data.get("momentum", users.current_users[player]["player"]["momentum"])
    rot = data.get("rotation", users.current_users[player]["player"]["rotation"])
    users.current_users[player]["player"]["position"] = pos
    users.current_users[player]["player"]["momentum"] = mom
    users.current_users[player]["player"]["rotation"] = rot
    for user in (set(users.current_users) - {username}):
        users.current_users[user]["updates"]["players"][player] = users.current_users[player]["player"]
    return True
