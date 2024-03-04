#!/usr/bin/env zsh

python3 -m venv virtual_env

virtual_env/bin/pip install --upgrade pip
virtual_env/bin/pip install -r requirements.txt