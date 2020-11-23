#!/bin/bash
#python application.py
gunicorn -k flask_sockets.worker -w 1 application:app
