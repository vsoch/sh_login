# Jupyter Notebook
For this example, we start with the base sh_container and then add a jupyter 
server to it!

## build

```
sudo singularity build sh_notebook Singularity.notebook
```
The only thing that we do in the [Singularity.notebook](Singularity.notebook)
file is to install jupyter via conda (already in the container) and then modify
the runscript to first run jupyter, and then to execute the same container runscript,
passing on variables. Since the container will generate all of our ports, we
simply generate and then pass on the jupyter (application) port.

## run
```
# Define variables up front
TMPDIR=$(mktemp -d /tmp/sh_login.XXXXXX)
NGINXPORT=$(( (UID*RANDOM)%55500 + 9000 ));
FLASKPORT=$(( (UID*RANDOM)%55500 + 9000 ));

singularity run --bind $TMPDIR:/var/log/nginx \
                --bind /run/user \
                sh_notebook start --tmpdir ${TMPDIR} --nginx ${NGINXPORT} --flask ${FLASKPORT}
```

**Stopped here** - this needs to be able to run as an instance, too many ghost process to do without that. Also we need to make sure that the jupyter knows about its proxy and doesn't detect its own port as "already in use" and then default to another.

 - https://github.com/jupyter/notebook/issues/625
