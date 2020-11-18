"""
application.py
==============
"""

from flask import (
    Flask, render_template, request, jsonify, flash,
    redirect, session, url_for
)
from flask_socketio import (
    SocketIO, join_room, leave_room, emit, rooms
)

from src import login


app = Flask(__name__, template_folder="./web/templates", static_folder="./web/static")
app.secret_key = b"gerry_secret_key"


@app.route("/")
def index():
    return render_template(
        "pages/index.html",
        context={}
    )

@app.route("/connect_user", methods=["POST"])
def connect_user():
    print(request.json)
    d = {}
    d["login_status"] = False
    if login.password_correct(
        request.json.get("username", ""),
        request.json.get("password", "")
    ):
        d["login_status"] = True
        d["username"] = request.json["username"]
        pid = add_user(request.json["username"])
        
    return jsonify(d)



@app.route("/test")
def test():
    return jsonify({
        "test": "success"
    })

if __name__ == "__main__":
    #socketio.run(app, debug=True)
    app.run()
