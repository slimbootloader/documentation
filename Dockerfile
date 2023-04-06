FROM ubuntu:22.04

RUN apt-get update
RUN apt-get -y install python3 python3-pip graphviz git
RUN pip install sphinx==6.1.3 docutils==0.18.1 sphinx-rtd-theme==1.2.0 sphinxcontrib-websupport==1.2.4 sphinxcontrib-jquery

RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo

USER docker
CMD /bin/bash
