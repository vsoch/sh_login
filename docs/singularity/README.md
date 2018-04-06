# Singularity Container
The work will sh_login not be complete until we are able to spawn a Singularity namespace
that can allow for input variables to the startscript, and an isolated network space.
Without this, we have no good way to run ports but not expose them to the host.

## What is working?
Servers (e.g., jupyter) that provide their own tokens ARE working. You can
skip the below and just see [examples/notebook](examples/notebook).

## What isn't working?
The sh_login isn't working because we need an isolated network space.
A summary of steps to get up to errors is given.
First, build the container. You can use the [Makefile](../../Makefile)


```
make singularity
```

or just run the build yourself!

```
sudo singularity build sh_container Singularity
```

The container has the python module sh_login installed. The container also contains
a web server that is started with the startscript that will write a nginx configuration
on the fly, and run nginx.

 - the server port generated for nginx is in the range that doesn't require root
 - the nginx log cannot be disabled and must be bound from the host to write


## Usage
Since the above largely doesn't work, we have to run the above with "run" and
create a ghost process for nginx (we are unable to kill it after).

For the above, we rely on a Control+C to kill the instance, however this doesn't
stop the nginx web server and it remains as a ghost process. The ideal usage 
starts an instance (in a separate namespace) but we cannot do this now because 
we don't see any logging. As a workaround, we are going to generate all of
the required secrets outside of the container first, and then give them to
the instance. This includes various ports, a temporary directory, and a token.

```
# Define variables up front
TMPDIR=$(mktemp -d /tmp/sh_login.XXXXXX)
NGINXPORT=$(( (UID*RANDOM)%55500 + 9000 ));
FLASKPORT=$(( (UID*RANDOM)%55500 + 9000 ));
APPPORT=8787;

singularity run --bind $TMPDIR:/var/log/nginx sh_container start \
                --tmpdir ${TMPDIR} \
                --nginx "${NGINXPORT}" \
                --flask "${FLASKPORT}" \
                --port "${APPPORT}"
```
```
Generating shell login portal...
logs: /tmp/sh_login.hU9mjN
port: 51500
token: f393ccf9-e3f3-42c1-a1ee-efa87fdfbb83
Server logging will be in /tmp/sh_login.hU9mjN

Testing nginx configuration...
nginx: the configuration file /tmp/sh_login.hU9mjN/nginx.conf syntax is ok
nginx: configuration file /tmp/sh_login.hU9mjN/nginx.conf test is successful
Nginx running at http://127.0.0.1:51500
[2018-04-05 16:20:19 +0000] [23761] [INFO] Starting gunicorn 19.7.1
[2018-04-05 16:20:19 +0000] [23761] [INFO] Starting gunicorn 19.7.1
[2018-04-05 16:20:19 +0000] [23761] [INFO] Listening at: http://0.0.0.0:48000 (23761)
[2018-04-05 16:20:19 +0000] [23761] [INFO] Listening at: http://0.0.0.0:48000 (23761)
[2018-04-05 16:20:19 +0000] [23761] [INFO] Using worker: sync
[2018-04-05 16:20:19 +0000] [23761] [INFO] Using worker: sync
[2018-04-05 16:20:19 +0000] [23767] [INFO] Booting worker with pid: 23767
[2018-04-05 16:20:19 +0000] [23767] [INFO] Booting worker with pid: 23767
[2018-04-05 16:20:19 +0000] [23768] [INFO] Booting worker with pid: 23768
[2018-04-05 16:20:19 +0000] [23768] [INFO] Booting worker with pid: 23768
[2018-04-05 16:20:19 +0000] [23769] [INFO] Booting worker with pid: 23769
[2018-04-05 16:20:19 +0000] [23769] [INFO] Booting worker with pid: 23769
[2018-04-05 16:20:19 +0000] [23770] [INFO] Booting worker with pid: 23770
[2018-04-05 16:20:19 +0000] [23770] [INFO] Booting worker with pid: 23770
[2018-04-05 16:20:19 +0000] [23771] [INFO] Booting worker with pid: 23771
[2018-04-05 16:20:19 +0000] [23771] [INFO] Booting worker with pid: 23771
...
```

We don't actually go anywhere when the token is entered, because we haven't
defined an application to run. To see examples with specific applications, check 
out the [examples](examples) pages. The problem is that even if we get something
running at a different port that is successfully redirected with a correct
token, someone could still discover the port and get there without the token.
We could get around this if we could set up this server in its own network
space, and then not expose the protected ports (and only as a proxy through the 
flask application).


## Ideal Usage
Ideally, the startscript in the container would print output to the console and
we wouldn't need to define these up front, but this isn't the case.

```
# Ports for nginx (primary), Flask (controller) and our web app (e.g., rstudio)
NGINXPORT=$(( (UID*RANDOM)%55500 + 9000 ));
FLASKPORT=$(( (UID*RANDOM)%55500 + 9000 ));
APPPORT=8787;

# Secret token
TOKEN=$(uuidgen -r);

# Temporary directory for nginx and for user bind (needs writable)
TMPDIR=$(mktemp -d /tmp/sh_login.XXXXXX)
```

We need the temporary directory so that the server can start and have write
permission for logs, and have them be accessible for the user. For this example,
let's start a jupyter notebook on port 8888 and then hide it behind a portal.

```
echo "Generating shell login portal...";
echo "logs:" ${TMPDIR};
echo "port: ${APPPORT}";
echo "token: ${TOKEN}";

singularity instance.start --bind $TMPDIR:/var/log/nginx sh_container web start \
                           --tmpdir ${TMPDIR} \
                           --token "${TOKEN}" \
                           --nginx "${NGINXPORT}" \
                           --flask "${FLASKPORT}" \
                           --port "${APPPORT}"
```

## Summary of Problems
 - The port 8787 is not exposed via the Docker image, but with Singularity it may be. We would need to add an extra directive to ensure that the proxy to the port is only available from the main entrypoint.
