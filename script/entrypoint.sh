#!/bin/bash

usage () {

    echo "Usage:
          When starting the application, provide a port, and a token protected
              portal will be generated at the port.

              docker run <container> [start|help]
              docker run <container> start --port 8888

          Commands:
             help: show help and exit
             start: the application

          Options:              
             token: a token to ask the user for. The token must match what
                    the user enters at the entrypoint to get access to the
                    port.

             port: the port to serve the Flask application. Cannot be 5000.
         "
}

SH_LOGIN_START="no"
SH_LOGIN_PORT=8787

if [ $# -eq 0 ]; then
    usage
    exit
fi

while true; do
    case ${1:-} in
        -h|--help|help)
            usage
            exit
        ;;
        -s|--start|start)
            SH_LOGIN_START="yes"
            shift
        ;;
        -t|--token|token)
            shift
            SH_LOGIN_TOKEN="${1:-}"
            export SH_LOGIN_TOKEN
            shift
        ;;
        -p|--port|port)
            shift
            SH_LOGIN_PORT="${1:-}"
            shift
        ;;
        -*)
            echo "Unknown option: ${1:-}"
            exit 1
        ;;
        *)
            break
        ;;
    esac
done

# A token is required

export SH_LOGIN_PORT

# Functions

function prepare_nginx() {
    PORT=$1
    TOKEN=$2
    template=$(mktemp /tmp/sh_login.XXXXXX)
    cp /code/script/nginx/nginx.gunicorn.conf $template
    sed -i -e 's/SH_LOGIN_PORT/${PORT}/g' $template
    sed -i -e 's/SH_LOGIN_TOKEN/${TOKEN}/g' $template
    mv $template /etc/nginx/nginx.conf
}


# Are we starting the server?

if [ "${SH_LOGIN_START}" == "yes" ]; then

    SH_LOGIN_TOKEN=$(uuidgen -r)
    export SH_LOGIN_TOKEN 

    echo "Generating shell login portal..."
    echo "port: ${SH_LOGIN_PORT}"
    echo "token: ${SH_LOGIN_TOKEN}" 

    # Prepare the template
    prepare_nginx $SH_LOGIN_PORT $SH_LOGIN_TOKEN

    echo
    service nginx start
    touch /tmp/gunicorn.log
    touch /tmp/gunicorn-access.log
    tail -n 0 -f /tmp/gunicorn*.log &

    exec  /opt/conda/bin/gunicorn sh_login.wsgi:app \
                  --bind 0.0.0.0:5000 \
                  --workers 5 \
                  --log-level=info \
                  --timeout 900 \
                  --log-file=/tmp/gunicorn.log \
                  --access-logfile=/tmp/gunicorn-access.log  \
            "$@" & service nginx restart

    # simple manual command could be
    # service nginx start
    # /opt/conda/bin/gunicorn -w 2 -b 0.0.0.0:5000 --timeout 900 --log-level debug sh_login.wsgi:app
    # service nginx restart

    # Keep container running if we get here
    tail -f /dev/null
    exit
else
    usage
fi
