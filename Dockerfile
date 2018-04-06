FROM continuumio/miniconda3
MAINTAINER vsochat@stanford.edu

# docker build -t vanessa/sh_login .

RUN apt-get update
RUN apt-get -y install apt-utils cmake wget unzip libffi-dev libssl-dev \
                       vim nginx nginx-extras uuid-runtime

ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

ENV PATH /opt/conda/bin:$PATH
RUN mkdir /code

ADD . /code
WORKDIR /code

# Set up nginx
RUN cp /code/script/nginx/nginx.conf /etc/nginx/nginx.conf && \
    cp /code/sh_login/config_dummy.py /code/sh_login/config.py && \
    chmod u+x /code/script/generate_key.sh && \
    /bin/bash /code/script/generate_key.sh /code/sh_login/config.py && \
    chmod a+w /var/log/nginx/access.log /var/log/nginx/error.log && \
    service nginx start # just to generate /run/nginx.pid

RUN /opt/conda/bin/python setup.py install && \
    /opt/conda/bin/pip install --upgrade pip && \
    /opt/conda/bin/pip install gunicorn

# Clean up
RUN apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENTRYPOINT ["/bin/bash", "/opt/conda/bin/sh_login"]
EXPOSE 5000
EXPOSE 80
