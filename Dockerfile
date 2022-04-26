FROM ubuntu:18.04

RUN apt-get update
RUN apt-get -y install python python-pip graphviz
RUN pip install sphinx==1.8.1 docutils==0.14 sphinx-rtd-theme==0.4.2 sphinxcontrib-websupport==1.1.0

RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo

USER docker
CMD /bin/bash
