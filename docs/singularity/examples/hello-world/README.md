# Hello World
For this example, we start with the base sh_container and then start a small
python server serving a static web application. This would be an easy way to secure
a static web application behind a password protected portal.

## build

```
sudo singularity build sh_helloworld Singularity.helloworld
```

## run
```
# Define variables up front
export TMPDIR=$(mktemp -d /tmp/sh_login.XXXXXX)
export NGINXPORT=$(( (UID*RANDOM)%55500 + 9000 ));
export FLASKPORT=$(( (UID*RANDOM)%55500 + 9000 ));

singularity run --bind $TMPDIR:/var/log/nginx \
                sh_helloworld start --tmpdir ${TMPDIR} --nginx ${NGINXPORT} --flask ${FLASKPORT}
```

