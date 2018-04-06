# Shell Login Portal

This is an experiment to provide a general web server to wrap access to
a particular port served by nginx. We do this by having the main nginx
root (/) serve as a proxy for the flask application, and then the Flask
application expects a particular environment variable (defined at runtime)
to check against a token provided by the user. If the token is correct,
the Flask response adds a header to authenticate it as so, and returns
the response to the user. If the response is incorrect, the user is 
returned permission denied (403). The user cannot go to the port to
bypass the application because of the proxy, and not exposing the port
directly. 

 - Docker works fairly well, as we can not expose particular ports to the host
 - Singularity does not, because all ports are shared

See the [docs](docs) for details.
