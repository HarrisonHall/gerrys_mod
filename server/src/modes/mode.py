import datetime
from time import time as make_timestamp
from copy import deepcopy
import random

random.seed()

class Mode:
    DISCONNECT_TIME = 3
    TIME_LIMIT = 60*5

    def __init__(self):
        self.settings = {
            "map": "fp_hub",
            "serv_version": 0,
            "mode": "fp",
            "random_seed": random.randint(0, 100)
        }
        self.start()

    def add_object(self, username, obj, values):
        assert (obj not in self.objects), "Cannot create object that already exists"
        self.objects[obj] = {
            "position": values.get("position", [0, 0, 0]),
            "momentum": values.get("momentum", [0, 0, 0]),
            "rotation": values.get("rotation", [0, 0, 0]),
            "timestamp": make_timestamp(),
            "timestamps": {
                username: values.get("timestamp", -1),
            },
            "last_update_from": username,
            "type": values["type"],
            "data": values.get("data", {}),
            "kill": False,
        }
        return None

    def add_player(self, username):
        self.users[username] = {
            "player": self.base_player(),
            "updates": {
                "players": {}
            },
            "just_joined": True,
            "last_time": datetime.datetime.now(),
            "last_given_timestamp": 0
        }
        return username

    def base_player(self):
        return {
            "position": [-1000, -1000, -1000],
            "momentum": [0, 0, 0],
            "rotation": [0, 0, 0],
            "model": "seagal",
            "vrot": 0,
            "is_crouching": False,
            "slide_time": 0,
            "data": {}
        }

    def change_map(self, m):
        if m != self.settings["map"]:
            self.settings["map"] = m
            self.settings["serv_version"] += 1
            return True
        return False

    def custom_update(self, obj):
        # TODO: Implemnt on a per-game basis
        return {}

    def current_player_count(self):
        return len(self.users)

    def flush_updates(self, username : str) -> bool:
        if username not in self.users:
            return False
        self.users[username]["updates"] = {
            "players": {}
        }
        return True

    def get_leader(self):
        if len(self.users) == 0:
            return ""
        return self.users[0]

    def get_settings(self):
        return self.settings

    def object_update_valid(self, username, obj, new_timestamp):
        return self.objects.get(obj, {}).get("timestamps", {}).get(username, -1) < new_timestamp

    def other_users(self, username):
        return list(set(self.users.keys()) - set([username]))

    def push_update(self, obj):
        """
        Put info in `updates` section of the object, which gets flushed after
        being sent to each player.
        """
        players = obj.get("players", {})
        username = obj.get("username", "")
        for user in self.other_users(username):
            for new_user, info in players.items():
                print(f"telling {user} that {new_user} took damage")
                self.users[user]["updates"]["players"][new_user] = {
                    "damage": info.get("damage", 0)
                }
        return {}

    def settings_valid(self, new_settings):
        return new_settings.get("serv_version", -1) == self.settings["serv_version"]

    def start(self):
        self.users = {}
        self.objects = {}
        self.start_time = datetime.datetime.now()

    def take_damage(self, obj):
        return self.update_damage(obj)

    def timestamp_valid(self, username, new_timestamp):
        assert (username in self.users), f"Username not in users: {username}"
        if new_timestamp > self.users[user]["last_given_timestamp"]:
            self.users[user]["last_given_timestamp"] = new_timestamp
            return True
        return False

    def restart(self):
        self.start_time = datetime.datetime.now()

    def remove_object(self, username : str, obj : str) -> bool:
        assert (obj in self.objects), f"Object not in objects: {obj}"
        del self.objects[obj]
        return True

    def remove_user(self, user : str) -> bool:
        if user not in self.users:
            return False
        del self.users[user]
        return True

    def remove_old_users(self):
        to_remove = []
        current_time = datetime.datetime.now()
        for user in self.users:
            last_time = self.users[user]["last_time"]
            if (current_time - last_time).total_seconds() > self.DISCONNECT_TIME:
                to_remove.append(user)
        for user in to_remove:
            self.remove_user(user)
        if len(to_remove) > 0:
            print("Removed old users:", to_remove)
        return to_remove

    def user_pinged(self, username : str) -> bool:
        if username not in self.users:
            return False
        self.users[username]["last_time"] = datetime.datetime.now()
        return True

    def update_damage(self, obj):
        # TODO, probably deprecated
        for user, info in obj["players"].items():
            self.users[user]["updates"]["players"][user] = {
                "damage": info["damage"]
            }
        return {}

    def update_game(self, obj):
        """
        Endpoint for updating players and sending the new updated information
        back out.
        Typically reached after a Person object sends an update.
        """
        # Get variables
        username = obj.get("username")
        players = obj.get("players", [])

        if not self.settings_valid(obj.get("settings", {})):
            d = {
                "settings": self.get_settings(),
                "timestamp": make_timestamp(),
            }
            return d

        # update the rest of the players
        for player in players:
            self.update_player(username, player, obj["players"][player])

        # Send game update to player
        update = {
            "players": {
                user: self.users[user]["player"] for user in self.other_users(username)
            }
        }
        if username in self.users:
            update["players"][username] = deepcopy(
                self.users[username]["updates"]["players"].get(username, {})
            )
        f = update.get('players').get(username, {})
        if f != {}:
            print(f"Update for {username} is", f)

        # Do game logic
        self.user_pinged(username)
        self.remove_old_users()
        self.flush_updates(username)

        d = {
            "updates": update,
            "objects": self.objects,
            "timestamp": make_timestamp(),
            "settings": self.get_settings()
        }
        return d

    def update_info(self, obj):
        # Get variables
        username = obj.get("username", "")
        new_timestamp = obj.get("timestamp", -1)

        updates = obj.get("update", {})

        if not self.settings_valid(obj.get("settings", {})):
            d = {
                "settings": self.get_settings(),
                "timestamp": make_timestamp(),
            }
            return d

        for person in updates.get("people", {}):
            if "model" in updates["people"][person]:
                self.users[username]["player"]["model"] = updates["people"][person]["model"]

        objects = updates.get("objects", {})
        for obj in objects:
            if obj in self.objects:
                # Check timestamp before updating
                if self.object_update_valid(username, obj, new_timestamp):
                    self.update_object(username, obj, objects[obj], new_timestamp)
                    if objects[obj].get("kill", False):
                        del self.objects[obj]
            else:
                self.add_object(username, obj, objects[obj])

        return {}

    def update_object(self, username, object_name, obj, new_timestamp):
        old_obj = self.objects[object_name]
        old_obj["position"] = obj.get("position", old_obj["position"])
        old_obj["momentum"] = obj.get("momentum", old_obj["momentum"])
        old_obj["rotation"] = obj.get("rotation", old_obj["rotation"])
        old_obj["timestamp"] = make_timestamp()
        old_obj["timestamps"][username] = new_timestamp
        old_obj["last_update_from"] = username
        old_obj["data"] = obj.get("data", old_obj["data"])
        old_obj["kill"] = obj.get("kill", old_obj["kill"])

    def update_player(self, username, player, obj):
        """
        Update player info
        """
        if username == player and username not in self.users:
            self.add_player(username)
        if username != player and player not in self.users:
            return False

        pos = obj.get("position", self.users[player]["player"]["position"])
        mom = obj.get("momentum", self.users[player]["player"]["momentum"])
        rot = obj.get("rotation", self.users[player]["player"]["rotation"])
        vrot = obj.get("vrot", self.users[player]["player"]["vrot"])
        is_crouching = obj.get("is_crouching", self.users[player]["player"]["is_crouching"])
        slide_time = obj.get("slide_time", self.users[player]["player"]["slide_time"])
        dat = obj.get("data", self.users[player]["player"]["data"])
        
        self.users[player]["player"]["position"] = pos
        self.users[player]["player"]["momentum"] = mom
        self.users[player]["player"]["rotation"] = rot
        self.users[player]["player"]["vrot"] = vrot
        self.users[player]["player"]["is_crouching"] = is_crouching
        self.users[player]["player"]["slide_time"] = slide_time
        self.users[player]["player"]["data"] = dat
    
        for user in (set(self.users) - {username}):
            self.users[user]["updates"]["players"][player] = self.users[player]["player"]
        return True

    def update_settings(self, obj):
        username = obj.get("username", "")

        if "map" in obj:
            if obj["map"] != self.settings["map"]:
                self.settings["map"] = obj["map"]
                self.objects = {}
                for user in self.users:
                    self.users[user]["player"] = self.base_player()
                self.settings["serv_version"] += 1
        return {
            "settings": self.get_settings()
        }
