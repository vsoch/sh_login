'''

Copyright (c) 2018 Vanessa Sochat

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

'''

from flask import Flask
from flask_wtf.csrf import (
    CSRFProtect, 
    generate_csrf
)
from flask_cors import CORS

import random
import sys
import os

# SERVER CONFIGURATION #########################################################

class LoginServer(Flask):

    def __init__(self, *args, **kwargs):
        super(LoginServer, self).__init__(*args, **kwargs)
        self._setup()

    def _setup(self):
        '''obtain port and other variables in environment'''
        self.port = os.environ.get('SH_LOGIN_PORT')
        self.token = os.environ.get('SH_LOGIN_TOKEN')

app = LoginServer(__name__)
app.config.from_object('sh_login.config')

# Cors
cors = CORS(app, origins="http://127.0.0.1", 
            allow_headers=["Content-Type", 
                           "Authorization", 
                           "X-Requested-With",
                           "sh-login-token",
                           "Access-Control-Allow-Credentials"],
            supports_credentials=True)

app.config['CORS_HEADERS'] = 'Content-Type'

csrf = CSRFProtect(app)

import sh_login.views

# This is how the command line version will run
def start(port=5000, debug=False):
    bot.info("Nginx configuration is the worst.")
    app.run(host="localhost", debug=debug, port=port)
