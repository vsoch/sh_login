FROM vanessa/sh_login
MAINTAINER vsochat@stanford.edu

# docker build -t vanessa/sh_notebook .

ADD /start.sh /
RUN /opt/conda/bin/pip install jupyter
ENTRYPOINT ["/bin/bash", "/start.sh"]
EXPOSE 8787
