
next_id = 0
current_users = {}

users = {
    "admin": {
        "password": "dog"
    },
    "harry": {
        "password": "winston"
    }
}

def password_correct(username, password):
    if username in users:
        return users[username]["password"] == password
    return False

def add_user(username):
    new_id = next_id
    next_id += 1

    current_users[new_id] = {
        "username": username
    }
    return new_id
    
