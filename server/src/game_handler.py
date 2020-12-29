"""
game_handler.py
===============
"""
from json import load
from time import time as make_timestamp


from .modes import *


# Server Constants
CHANGE_LOBBY = "change_lobby"
CONNECT_USER = "connect_user"
CUSTOM_UPDATE = "custom_update"
LOGIN_STATUS = "login_status"
SERVER_SETTINGS = "server_settings"
#TAKE_DAMAGE = "take_damage"
PUSH_UPDATE = "push_update"
UPDATE_GAME = "update_game"
UPDATE_INFO = "update_info"
ENDPOINTS = [
    CONNECT_USER, LOGIN_STATUS, SERVER_SETTINGS,
    UPDATE_GAME, UPDATE_INFO, PUSH_UPDATE,
    CUSTOM_UPDATE, CHANGE_LOBBY
]

# Server Variables
lobbies = {}
user_to_lobby = {}
users = {}
raw_user_data = {}
with open("data/users.json", "r") as jsonfile:
    raw_user_data = load(jsonfile)

def add_user(obj : dict) -> bool:
    username = obj.get("username", "")
    lobby_name = obj.get("lobby", "DEFAULT")
    if lobby_name not in lobbies:
        make_lobby(lobby_name)
    
    _last_player_joined = str(username)
    users[username] = {
        "last_timestamp": make_timestamp(),
        "last_user_timestamp": -1
    }
    user_to_lobby[username] = lobby_name

    d = {}
    d["login_status"] = True
    d["username"] = obj["username"]
    #pid = add_user(obj["username"])
    d["settings"] = lobbies[lobby_name].get_settings()
    d["timestamp"] = make_timestamp()
    return d

def base_object_valid(obj):
    """
    False iff something is intrincically wrong with packet.
    """
    username = obj.get("username", False)
    if not username:
        print("No username")
        return False
    if username not in users:
        print("Username not a thing")
        return False
    timestamp = obj.get("timestamp", -1)
    if timestamp < users[username]["last_user_timestamp"]:
        print("Old timestamp")
        return False
    endpoint = obj.get("endpoint", "???")
    if not endpoint_valid(endpoint):
        print(f"Wrong endpoint: {endpoint}")
        return False
    if endpoint == CONNECT_USER:
        print("User reconnecting")
        return False
    return True

def can_add_user(obj):
    username = obj.get("username", False)
    password = obj.get("password", False)
    if username:
        if username in raw_user_data:
            if raw_user_data[username]["password"] == password:
                if username not in users:
                    return True
                elif (make_timestamp() - users[username]["last_timestamp"]) > 3:
                    users[username]["last_timestamp"] = -1
                    users[username]["last_user_timestamp"] = -1
                    return True
    return False

def change_lobby(obj : dict) -> dict:
    """
    Remove a player from current lobby, make new lobby ready for player.
    """
    username = obj.get("username")
    old_lobby_name = user_to_lobby[username]
    new_lobby_name = obj.get("new_lobby", old_lobby_name)
    old_lobby = lobbies[old_lobby_name]
    old_lobby.remove_user(username)
    if make_lobby(new_lobby_name):
        print("Made new lobby!")
    else:
        print("Did not make new lobby")
    new_lobby = lobbies[new_lobby_name]
    user_to_lobby[username] = new_lobby_name
    return {
        "settings": new_lobby.get_settings(),
        "timestamp": make_timestamp()
    }

def current_player_count():
    return str(len(users))

def endpoint_valid(e):
    return (e in ENDPOINTS)

def invalid_packet_response(obj):
    # TODO, make error codes
    return {
        "ERROR": f"Packet invalid {obj}"
    }

_last_player_joined = "Null"
def last_player_joined():
    return _last_player_joined

def make_lobby(lobby_name):
    """
    Makes lobby based on name.
    BASENAME_GAMEMODE_MAP
    """
    #assert lobby_name not in lobbies, f"Invalid: Lobby '{lobby_name}' already exists"
    if lobby_name in lobbies:
        return False
    parts = lobby_name.split("_")
    if len(parts) == 1:
        lobbies[lobby_name] = FreePlay(map_name="fp_hub") # TODO set map_name to fp_hubworld
    elif len(parts) == 2:
        print("TODO, make other lobby types")
    elif len(parts) == 3:
        if parts[1] == "fp":
            lobbies[lobby_name] = FreePlay(map_name=f"{parts[1]}_{parts[2]}")
            print(f"Made lobby {lobby_name} with map {lobbies[lobby_name].settings['map']}")
        else:
            return False
    else:
        return False
    return True

def user_pinged(username, new_timestamp) -> False:
    """
    Update user timestamp
    """
    assert username in users, f"Invalid: User '{username}' does not exist"
    users[username]["last_timestamp"] = make_timestamp()
    users[username]["last_user_timestamp"] = new_timestamp
    return True

def update(obj):
    endpoint = obj.get("endpoint")
    username = obj.get("username")
    lobby_name = user_to_lobby[username]
    if lobby_name not in lobbies:
        make_lobby(lobby_name)
    lobby = lobbies[user_to_lobby[username]]
    timestamp = obj.get("timestamp")
    
    d = {}
    user_pinged(username, timestamp)

    if endpoint == SERVER_SETTINGS:
        d = lobby.update_settings(obj)
    elif endpoint == UPDATE_INFO:
        d = lobby.update_info(obj)
    elif endpoint == UPDATE_GAME:
        #print("UPDATE GAME")
        d = lobby.update_game(obj)
    elif endpoint == PUSH_UPDATE:
        print("Pushing update")
        d = lobby.push_update(obj)
    elif endpoint == CHANGE_LOBBY:
        print("Changing lobby")
        d = change_lobby(obj)
    else:
        print("CUSTOM UPDATE")
        d = lobby.custom_update(obj)

    return d

