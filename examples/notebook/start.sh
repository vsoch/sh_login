#!/bin/bash

usage () {

    echo "Usage:
          This will generate token protected jupyter notebook at port 8787.

              docker run <container> [start|help]

          Commands:
             help: show help and exit
             start: the application
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
    cp /code/script/nginx.gunicorn.conf $template
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

    # Starting Jupyter
    /opt/conda/bin/jupyter notebook --port=8787 --no-browser &

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
