#!/bin/bash

export SH_LOGIN_PORT=8787

# Start tiny web server
echo "<h1>Hello Moto?</h1>" >> /code/index.html
/opt/conda/bin/python -m http.server $SH_LOGIN_PORT &

# Run the main entrypoint for sh_login
/code/script/entrypoint.sh start --port $SH_LOGIN_PORT
