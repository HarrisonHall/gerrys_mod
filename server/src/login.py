
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
            "momentum": [0, 0, 0]
        },
        "update": {
            "players": {}
        },
        "just_joined": True
    }
    return new_id
    
