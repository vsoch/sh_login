# Shell Login Portal

This is an experiment to provide a general web server to wrap access to
a particular port served by nginx. We do this by having the main nginx
root (/) serve as a proxy for the flask application, and then the Flask
application expects a particular environment variable (defined at runtime)
to check against a token provided by the user. The Flask application then
retrieves the page response, and returns to the user. The user is not able
to make this request.
