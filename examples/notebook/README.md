# Notebook

This example will show how to build a container with a jupyter notebook
behind this portal. We extend the sh_login container to customize the
entrypoint, and call it manually after our own custom commands to start
a jupyter notebook. Note that we don't have to use jupyter inside the application -
we could just as easily have it running on our host, and then give that port
to the sh_login container.

Build the container

```
docker build -t vanessa/sh_notebook .
```

Run the container

```
docker run vanessa/sh_notebook start
```
