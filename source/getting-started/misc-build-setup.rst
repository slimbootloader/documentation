.. _misc_setup_docker:


Miscellaneous: Dockers 
~~~~~~~~~~~~~~~~~~~~~~

.. note:: Using Dockers to build is optional.


**Step 1: Download Docker**

Install docker package::

  sudo apt-get install docker.io

Add yourself to the docker group::

  sudo usermod -aG docker $USER

Log out then re-login to Ubuntu


.. note:: If you are behind firewall, see |Docker Proxy Settings|.

.. |Docker Proxy Settings| raw:: html

   <a href="https://docs.docker.com/config/daemon/systemd/#httphttps-proxy" target="_blank">Docker Proxy Settings</a>


**Step 2: Build Docker Image**

Build docker image using Dockerfile::

  cd <slimboot_source_tree>
  docker build -t sbl --network=host .

**Step 3: Start Docker Container**

Run the container in the background::

  cd <slimboot_source_tree>
  docker run -it --rm --network=host --name=sbl -d -v $PWD:/tmp/work sbl


**Step 4: Build Inside Docker Container**

Build |SPN| inside running container::

  docker exec -w /tmp/work sbl python BuildLoader.py build <platform_name>


.. _misc_setup_Proxy:

Miscellaneous: Proxy Settings 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If your build host is behind company's firewall, it is important to set up proxy correctly.

On Linux::

    export HTTP_PROXY=http://<proxy_host>:<port>
    export HTTPS_PROXY=https://<proxy_host>:<port>

On Windows::

    set HTTP_PROXY=http://<proxy_host>:<port>
    set HTTPS_PROXY=https://<proxy_host>:<port>

Cloning repository behind firewall requires git proxy configuration::

    git config --global http.proxy http://<proxy_host>:<proxy_port>

