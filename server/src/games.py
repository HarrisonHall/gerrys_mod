import datetime

next_id = 0
current_users = {}

users = {
    "admin": {
        "password": "dog"
    },
    "harry": {
        "password": "winston"
    },
    "george": {
        "password": "george"
    },
    "kaleb": {
        "password": "jake"
    },
    "jacky": {
        "password": "felix"
    },
    "biraj": {
        "password": "biruja"
    }
}

def password_correct(username, password):
    if username in users:
        return users[username]["password"] == password
    return False

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

# BUG: first person never gets 2nd person
