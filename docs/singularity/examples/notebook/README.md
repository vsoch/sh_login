# Jupyter Notebook
This is just a jupyter notebook, in a container.

## build

```
sudo singularity build sh_notebook Singularity.notebook
```

## run
```
# Define variables up front
TMPDIR=$(mktemp -d /tmp/sh_login.XXXXXX)
NGINXPORT=$(( (UID*RANDOM)%55500 + 9000 ));
FLASKPORT=$(( (UID*RANDOM)%55500 + 9000 ));
singularity run --bind /run/user sh_notebook start
```
