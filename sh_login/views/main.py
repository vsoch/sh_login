'''
views.py: part of expfactory package

Copyright (c) 2017, Vanessa Sochat
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of the copyright holder nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

'''

from flask import (
    flash,
    jsonify,
    make_response,
    Response,
    render_template, 
    request, 
    redirect,
    session
)

from flask_wtf.csrf import generate_csrf
from flask_cors import cross_origin
from werkzeug import secure_filename

from sh_login.server import app
from .general import *
from .headless import *

from random import choice
import pickle
import logging
import os
import json

from sh_login.forms import EntryForm


# SECURITY #####################################################################

@app.after_request
def inject_csrf_token(response):
    response.headers.set('X-CSRF-Token', generate_csrf())
    return response
  

# Entry point to authenticate
@app.route('/', methods=['GET', 'POST'])
def home():

    if "token" not in session:
        form = EntryForm()
        return render_template('routes/entry.html', form=form)
    return redirect('/next')



def catch_all(path):
    return 'You want path: %s' % path
    
@app.route('/next', defaults={'path': ''}, methods=['GET'])
@app.route('/<path:path>')
def next(path):

    print('requested url %s' %path)

    # Headless mode requires logged in user with token
    if "token" not in session:
        return headless_denied()

    token = session.get('token')
    print("I found token %s" %token)

    import requests
    response = requests.get('http://127.0.0.1/%s' %path, 
                            headers={'sh-login-token':token})
    
    return Response(
        response.text,
        status=response.status_code,
        content_type=response.headers['content-type'],
    )

    response = redirect('/')
    response.headers['sh-login-token'] = token
    response.headers['http-sh-login-token'] = token
    #response.direct_passthrough=True
    #response = make_response(redirect('/entrypoint'), 301, {'sh_login_token': '"%s"' %token})
    print(response)
    print(response.__dict__)
    #response = redirect('/entrypoint' ,'/entrypoint', {'sh-login-token', token})
    #response.headers.set('sh-login-token', token)
    #response.headers.set('sh_login_token', token)
    #response.headers.set('http_sh_login_token', token)
    #response.headers.set('http-sh-login-token', token)
    return response
   

# Reset/Logout
@app.route('/logout', methods=['POST', 'GET'])
def logout():

    # If the user has finished, clear session
    if "token" in session:
        del session['token']

    if "subid" in session:
        del session['subid']
    return redirect('/')
