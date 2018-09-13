FROM ubuntu:18.04

ENV http_proxy http://proxy.jf.intel.com:911
ENV HTTP_PROXY http://proxy.jf.intel.com:911
ENV https_proxy http://proxy.jf.intel.com:911
ENV HTTPS_PROXY http://proxy.jf.intel.com:911
ENV ftp_proxy http://proxy.jf.intel.com:911
ENV FTP_PROXY http://proxy.jf.intel.com:911

RUN apt-get update
RUN apt-get -y install python python-pip graphviz

RUN pip install sphinx docutils sphinx-rtd-theme sphinxcontrib-websupport

RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo

USER docker
CMD /bin/bash
