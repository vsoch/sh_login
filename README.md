# Shell Login Portal

This is an experiment to provide a general web server to wrap access to
a particular port served by nginx. We do this by having the main nginx
root (/) serve as a proxy for the flask application, and then the Flask
application expects a particular environment variable (defined at runtime)
to check against a token provided by the user. The Flask application then
retrieves the page response, and returns to the user. The user is not able
to make this request.


## Future Problems to Consider
The following issues are going to arise porting Docker to Singularity

 - We cannot edit the nginx.gunicorn config at runtime, the folder will be read only. We either need to install/set to where user has write, or give user permission to change the file.
