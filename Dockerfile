FROM ubuntu:18.04

RUN apt-get update
RUN apt-get -y install python python-pip graphviz
RUN pip install sphinx docutils sphinx-rtd-theme sphinxcontrib-websupport

RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo

USER docker
CMD /bin/bash
