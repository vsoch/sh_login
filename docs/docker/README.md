# Docker
Docker is able to isolate the networking space, meaning we can have a jupyter
notebook (or other web application) running internally without needing to worry
about the port being exposed.


First, build the container. You can use the [Makefile](../../Makefile)

```
make docker
```

or just run the build yourself!

```
docker build -t sh_container .
```

## Overview
The container has the python module sh_login installed. The container also contains
a web server that is started with the startscript that will write a nginx configuration
on the fly, and run nginx.

 - the server port generated for nginx is in the range that doesn't require root
 - the nginx log cannot be disabled and must be bound from the host to write


## Usage
We are going to generate all of the required secrets outside of the container 
first, and then give them to the instance. This includes various ports, 
a temporary directory, and a token.

```
# Define variables up front
TMPDIR=$(mktemp -d /tmp/sh_login.XXXXXX)
NGINXPORT=$(( (UID*RANDOM)%55500 + 9000 ));
FLASKPORT=$(( (UID*RANDOM)%55500 + 9000 ));
APPPORT=$(( (UID*RANDOM)%55500 + 9000 ));
docker run -v $TMPDIR:/tmp  --expose ${NGINXPORT} --name sh_login sh_container start --tmpdir ${TMPDIR} \
                --nginx ${NGINXPORT} \
                --flask ${FLASKPORT} \
                --port ${APPPORT} \
                --cmd "tail -f /dev/null"
```
```
Generating shell login portal...
port: 63500
logs: /tmp/sh_login.eHsYac
nginx: 21000
token: 1afb9152-801c-4bd3-81e0-6447afa5f462
Server logging will be in /tmp/sh_login.eHsYac

Testing nginx configuration...
nginx: the configuration file /tmp/sh_login.eHsYac/nginx.conf syntax is ok
nginx: configuration file /tmp/sh_login.eHsYac/nginx.conf test is successful

Nginx running at http://127.0.0.1:21000
...
```
Then get the ipaddress:
```
ipaddress=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' sh_login)
echo "Go to http://$ipaddress:$NGINXPORT"
Go to http://172.17.0.4:21000
```

Importantly, you *shouldn't be able to go to port 63500. You can now enter the
token, and you won't actually go anywhere because there isn't a web application.
See some of the examples to actually go places. Don't forget to stop your container

```
docker stop sh_login
```
