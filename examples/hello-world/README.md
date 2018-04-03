# Hello World

This example will show how to build a container with some portal being served
at a port behind a token login screen. We extend the sh_login container 
to customize the entrypoint, and call it manually after our own custom commands to start
a "Hello World" server. 

Build the container

```
docker build -t vanessa/sh_helloworld .
```

Run the container

```
docker run -d vanessa/sh_helloworld start
```
